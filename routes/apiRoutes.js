const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('../config/db');
const { requireAuth } = require('../middleware/authMiddleware');
const { generateTimetable, PERIOD_SLOTS } = require('../services/timetableGenerator');
const { detectConflicts } = require('../services/conflictDetector');
const router = express.Router();

const resources = {
  teachers: { table: 'teachers', fields: ['teacher_id', 'employee_id', 'full_name', 'email', 'phone', 'gender', 'qualification', 'max_daily_periods', 'max_weekly_periods', 'status'] },
  classes: { table: 'classes', fields: ['class_number', 'class_name', 'academic_year', 'class_teacher_id', 'total_sections'] },
  sections: { table: 'sections', fields: ['section_name', 'class_id', 'academic_year', 'student_count', 'class_teacher_id', 'classroom_id'] },
  subjects: { table: 'subjects', fields: ['subject_code', 'subject_name', 'class_id', 'weekly_periods_required', 'subject_type', 'preferred_period', 'required_room_type'] },
  classrooms: { table: 'classrooms', fields: ['room_number', 'building', 'floor', 'capacity', 'room_type', 'facilities', 'status'] },
  'teacher-availability': { table: 'teacher_availability', fields: ['teacher_id', 'day', 'period_number', 'status'] },
  'teacher-subjects': { table: 'teacher_subjects', fields: ['teacher_id', 'subject_id', 'class_id', 'section_id'] },
  'class-subjects': { table: 'class_subjects', fields: ['section_id', 'subject_id', 'teacher_id', 'periods_per_week'] }
};

const cleanBody = (fields, body = {}) => Object.fromEntries(fields.filter(field => body[field] !== undefined).map(field => [field, body[field]]));
const periodToTime = (periodNumber) => {
  const slot = PERIOD_SLOTS[Number(periodNumber) - 1] || '08:30 - 09:15';
  return slot;
};

router.post('/auth/login', async (req, res, next) => {
  try {
    const [rows] = await pool.query('SELECT id,email,name,password_hash,role FROM users WHERE email=?', [req.body.email]);
    const user = rows[0];
    if (!user || !(await bcrypt.compare(req.body.password || '', user.password_hash))) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }
    delete user.password_hash;
    req.session.user = user;
    res.json({ success: true, user });
  } catch (error) {
    next(error);
  }
});

router.post('/auth/logout', (req, res) => req.session.destroy(() => res.json({ success: true })));
router.get('/auth/me', (req, res) => res.json({ success: true, user: req.session.user || null }));

for (const [name, config] of Object.entries(resources)) {
  router.get(`/${name}`, requireAuth, async (req, res, next) => {
    try {
      const [rows] = await pool.query(`SELECT * FROM ${config.table} ORDER BY id DESC`);
      res.json({ success: true, data: rows });
    } catch (error) {
      next(error);
    }
  });

  router.get(`/${name}/:id`, requireAuth, async (req, res, next) => {
    try {
      const [rows] = await pool.query(`SELECT * FROM ${config.table} WHERE id=?`, [req.params.id]);
      if (!rows[0]) return res.status(404).json({ success: false, message: 'Record not found' });
      res.json({ success: true, data: rows[0] });
    } catch (error) {
      next(error);
    }
  });

  router.post(`/${name}`, requireAuth, async (req, res, next) => {
    try {
      const data = cleanBody(config.fields, req.body);
      const keys = Object.keys(data);
      if (!keys.length) return res.status(400).json({ success: false, message: 'No valid fields supplied' });
      const [result] = await pool.query(`INSERT INTO ${config.table} (${keys.join(',')}) VALUES (${keys.map(() => '?').join(',')})`, keys.map(key => data[key]));
      res.status(201).json({ success: true, id: result.insertId });
    } catch (error) {
      next(error);
    }
  });

  router.put(`/${name}/:id`, requireAuth, async (req, res, next) => {
    try {
      const data = cleanBody(config.fields, req.body);
      const keys = Object.keys(data);
      if (!keys.length) return res.status(400).json({ success: false, message: 'No valid fields supplied' });
      await pool.query(`UPDATE ${config.table} SET ${keys.map(key => `${key}=?`).join(',')} WHERE id=?`, [...keys.map(key => data[key]), req.params.id]);
      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  });

  router.delete(`/${name}/:id`, requireAuth, async (req, res, next) => {
    try {
      await pool.query(`DELETE FROM ${config.table} WHERE id=?`, [req.params.id]);
      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  });
}

router.get('/dashboard', requireAuth, async (req, res, next) => {
  try {
    const counts = {};
    for (const [key, config] of Object.entries(resources)) {
      const [rows] = await pool.query(`SELECT COUNT(*) count FROM ${config.table}`);
      counts[key] = rows[0].count;
    }
    const [timetable] = await pool.query('SELECT COUNT(*) count FROM timetable');
    const [conflicts] = await pool.query("SELECT COUNT(*) count FROM conflicts WHERE status <> 'Resolved'");
    res.json({ success: true, data: { ...counts, timetable: timetable[0].count, conflicts: conflicts[0].count } });
  } catch (error) {
    next(error);
  }
});

router.post('/timetable/generate', requireAuth, async (req, res, next) => {
  try {
    const [assignments] = await pool.query(`
      SELECT cs.*, s.subject_name, s.required_room_type, s.weekly_periods_required,
             sec.section_name, sec.student_count,
             t.full_name AS teacher_name, t.max_daily_periods, t.max_weekly_periods
      FROM class_subjects cs
      JOIN sections sec ON sec.id = cs.section_id
      JOIN subjects s ON s.id = cs.subject_id
      LEFT JOIN teachers t ON t.id = cs.teacher_id
      ORDER BY s.weekly_periods_required DESC, sec.student_count DESC
    `);
    const [[teachers], [sections], [classrooms], [availability]] = await Promise.all([
      pool.query('SELECT * FROM teachers'),
      pool.query('SELECT * FROM sections'),
      pool.query('SELECT * FROM classrooms'),
      pool.query('SELECT * FROM teacher_availability')
    ]);

    const result = generateTimetable({ assignments, teachers, sections, classrooms, availability });

    await pool.query('DELETE FROM conflicts');
    for (const item of result.conflicts || []) {
      await pool.query(
        'INSERT INTO conflicts (type, severity, description, teacher_id, classroom_id, section_id, day, period_number, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [item.type, item.severity, item.description, item.teacher_id || null, item.classroom_id || null, item.section_id || null, item.day || null, item.period_number || null, 'Open']
      );
    }

    res.json({ success: true, ...result });
  } catch (error) {
    next(error);
  }
});

router.get('/timetable', requireAuth, async (req, res, next) => {
  try {
    const [rows] = await pool.query(`
      SELECT t.*, s.subject_name, sec.section_name, te.full_name AS teacher_name, c.room_number, c.room_type,
             CASE t.period_number
               WHEN 1 THEN '08:30 - 09:15'
               WHEN 2 THEN '09:15 - 10:00'
               WHEN 3 THEN '10:00 - 10:45'
               WHEN 4 THEN '11:00 - 11:45'
               WHEN 5 THEN '11:45 - 12:30'
               WHEN 6 THEN '13:15 - 14:00'
               WHEN 7 THEN '14:00 - 14:45'
               WHEN 8 THEN '14:45 - 15:30'
               ELSE '08:30 - 09:15'
             END AS time_slot
      FROM timetable t
      JOIN subjects s ON s.id = t.subject_id
      JOIN sections sec ON sec.id = t.section_id
      JOIN teachers te ON te.id = t.teacher_id
      JOIN classrooms c ON c.id = t.classroom_id
      ORDER BY FIELD(t.day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'), t.period_number
    `);
    res.json({ success: true, data: rows });
  } catch (error) {
    next(error);
  }
});

router.post('/timetable/save', requireAuth, async (req, res, next) => {
  try {
    await pool.query('DELETE FROM timetable');
    for (const item of req.body.timetable || []) {
      const periodNumber = Number(item.period_number || 1);
      const [start, end] = (item.time_slot || periodToTime(periodNumber)).split(' - ');
      await pool.query(
        'INSERT INTO timetable (section_id, subject_id, teacher_id, classroom_id, day, period_number, start_time, end_time, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [item.section_id, item.subject_id, item.teacher_id, item.classroom_id, item.day, periodNumber, start || '08:30', end || '09:15', 'Draft']
      );
    }
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

router.delete('/timetable/reset', requireAuth, async (req, res, next) => {
  try {
    await pool.query('DELETE FROM timetable');
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

router.get('/conflicts', requireAuth, async (req, res, next) => {
  try {
    const [rows] = await pool.query('SELECT * FROM conflicts ORDER BY FIELD(severity, "Critical", "High", "Medium", "Low"), id DESC');
    res.json({ success: true, data: rows });
  } catch (error) {
    next(error);
  }
});

router.post('/conflicts/check', requireAuth, async (req, res, next) => {
  try {
    const [entries] = await pool.query('SELECT * FROM timetable');
    const [teachers] = await pool.query('SELECT * FROM teachers');
    const [sections] = await pool.query('SELECT * FROM sections');
    const [classrooms] = await pool.query('SELECT * FROM classrooms');
    const found = detectConflicts(entries, teachers, sections, classrooms);
    res.json({ success: true, data: found });
  } catch (error) {
    next(error);
  }
});

router.patch('/conflicts/:id/resolve', requireAuth, async (req, res, next) => {
  try {
    await pool.query("UPDATE conflicts SET status='Resolved' WHERE id=?", [req.params.id]);
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

router.get('/reports/teacher-workload', requireAuth, async (req, res, next) => {
  try {
    const [rows] = await pool.query(`
      SELECT te.full_name AS name, te.qualification AS department, COUNT(t.id) AS weekly_hours, te.max_weekly_periods AS max_weekly_periods
      FROM teachers te
      LEFT JOIN timetable t ON t.teacher_id = te.id
      GROUP BY te.id
      ORDER BY weekly_hours DESC
    `);
    res.json({ success: true, data: rows });
  } catch (error) {
    next(error);
  }
});

router.get('/reports/classroom-utilization', requireAuth, async (req, res, next) => {
  try {
    const [rows] = await pool.query(`
      SELECT c.room_number, c.room_type, c.capacity, COUNT(t.id) AS occupied_slots
      FROM classrooms c
      LEFT JOIN timetable t ON t.classroom_id = c.id
      GROUP BY c.id
      ORDER BY occupied_slots DESC
    `);
    res.json({ success: true, data: rows });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
