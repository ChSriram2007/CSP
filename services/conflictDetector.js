function detectConflicts(entries = [], teachers = [], sections = [], classrooms = []) {
  const conflicts = [];
  const seen = new Map();

  const add = (type, severity, description, entry) => {
    conflicts.push({
      type,
      severity,
      description,
      teacher_id: entry.teacher_id || null,
      classroom_id: entry.classroom_id || null,
      section_id: entry.section_id || null,
      day: entry.day || null,
      period_number: entry.period_number || null,
      status: 'Open'
    });
  };

  for (const entry of entries) {
    const periodNumber = Number(entry.period_number || 1);
    const key = `${entry.day}|${periodNumber}`;

    for (const [resource, label] of [['teacher_id', 'Teacher clash'], ['section_id', 'Section clash'], ['classroom_id', 'Classroom clash']]) {
      if (!entry[resource]) continue;
      const resourceKey = `${key}|${resource}|${entry[resource]}`;
      if (seen.has(resourceKey)) {
        add(label, 'Critical', `${label}: resource ${entry[resource]} is double-booked`, entry);
      }
      seen.set(resourceKey, entry.id || true);
    }

    const section = sections.find(item => String(item.id) === String(entry.section_id));
    const room = classrooms.find(item => String(item.id) === String(entry.classroom_id));

    if (section && room && Number(room.capacity || 0) < Number(section.student_count || 0)) {
      add('Capacity violation', 'High', `Room capacity ${room.capacity} is below section size ${section.student_count}`, entry);
    }

    if (room && entry.room_type && String(room.room_type) !== String(entry.room_type)) {
      add('Room type mismatch', 'High', `Required ${entry.room_type}, assigned ${room.room_type}`, entry);
    }

    const teacher = teachers.find(item => String(item.id) === String(entry.teacher_id));
    if (teacher && String(teacher.status).toLowerCase() === 'inactive') {
      add('Teacher availability violation', 'High', 'Inactive teacher assigned to timetable', entry);
    }
  }

  return conflicts;
}

module.exports = { detectConflicts };
