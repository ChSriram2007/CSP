const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
const PERIOD_SLOTS = ['08:30 - 09:15', '09:15 - 10:00', '10:00 - 10:45', '11:00 - 11:45', '11:45 - 12:30', '13:15 - 14:00', '14:00 - 14:45', '14:45 - 15:30'];

function periodToTime(periodNumber) {
  return PERIOD_SLOTS[(Number(periodNumber) || 1) - 1] || PERIOD_SLOTS[0];
}

function generateTimetable({ assignments = [], teachers = [], sections = [], classrooms = [], availability = [] }) {
  const timetable = [];
  const conflicts = [];
  const occupied = new Set();
  const teacherDaily = new Map();
  const teacherWeekly = new Map();
  const teacherAvailability = new Set(
    availability
      .filter(item => String(item.status).toUpperCase() !== 'UNAVAILABLE')
      .map(item => `${item.teacher_id}|${item.day}|${item.period_number}`)
  );

  const sorted = [...assignments].sort((a, b) => {
    const aPriority = Number(a.weekly_periods_required || 0) + Number(a.student_count || 0);
    const bPriority = Number(b.weekly_periods_required || 0) + Number(b.student_count || 0);
    return bPriority - aPriority;
  });

  for (const assignment of sorted) {
    const requiredPeriods = Number(assignment.periods_per_week || assignment.weekly_periods_required || 1);
    const teacher = teachers.find(item => String(item.id) === String(assignment.teacher_id));
    const section = sections.find(item => String(item.id) === String(assignment.section_id));
    const roomType = assignment.required_room_type || 'Normal Classroom';

    for (let periodIndex = 0; periodIndex < requiredPeriods; periodIndex += 1) {
      let placed = false;

      for (const day of DAYS) {
        if (placed) break;
        for (const slotIndex of PERIOD_SLOTS.keys()) {
          const periodNumber = slotIndex + 1;
          const dayKey = `${assignment.teacher_id}|${day}|${periodNumber}`;
          const sectionKey = `${assignment.section_id}|${day}|${periodNumber}`;
          const teacherLimit = Number(teacher?.max_daily_periods || 6);
          const weeklyLimit = Number(teacher?.max_weekly_periods || 30);

          if (teacherAvailability.size && !teacherAvailability.has(dayKey)) continue;
          if ((teacherDaily.get(`${assignment.teacher_id}|${day}`) || 0) >= teacherLimit) continue;
          if ((teacherWeekly.get(assignment.teacher_id) || 0) >= weeklyLimit) continue;
          if (occupied.has(sectionKey) || occupied.has(`teacher|${assignment.teacher_id}|${day}|${periodNumber}`)) continue;

          const room = classrooms.find(item => {
            const sameType = String(item.room_type || '').toLowerCase() === String(roomType || '').toLowerCase() || roomType === 'Normal Classroom';
            const roomFree = !occupied.has(`${item.id}|${day}|${periodNumber}`);
            const capacityOk = Number(item.capacity || 0) >= Number(section?.student_count || 0);
            const active = String(item.status || 'Available') === 'Available';
            return active && sameType && roomFree && capacityOk;
          });

          if (!room) continue;

          const entry = {
            allocation_id: assignment.id,
            section_id: assignment.section_id,
            subject_id: assignment.subject_id,
            teacher_id: assignment.teacher_id,
            classroom_id: room.id,
            subject_name: assignment.subject_name,
            teacher_name: assignment.teacher_name || teacher?.full_name,
            section_name: assignment.section_name || section?.section_name,
            room_number: room.room_number,
            room_type: room.room_type,
            day,
            period_number: periodNumber,
            time_slot: periodToTime(periodNumber)
          };

          timetable.push(entry);
          occupied.add(`${room.id}|${day}|${periodNumber}`);
          occupied.add(`teacher|${assignment.teacher_id}|${day}|${periodNumber}`);
          occupied.add(sectionKey);
          teacherDaily.set(`${assignment.teacher_id}|${day}`, (teacherDaily.get(`${assignment.teacher_id}|${day}`) || 0) + 1);
          teacherWeekly.set(assignment.teacher_id, (teacherWeekly.get(assignment.teacher_id) || 0) + 1);
          placed = true;
          break;
        }
      }

      if (!placed) {
        conflicts.push({
          type: 'Scheduling conflict',
          severity: 'High',
          description: `Unable to place ${assignment.subject_name || 'subject'} for ${assignment.section_name || 'section'} without violating constraints.`,
          teacher_id: assignment.teacher_id,
          section_id: assignment.section_id,
          day: DAYS[0],
          period_number: 1,
          status: 'Open'
        });
      }
    }
  }

  const score = conflicts.length ? Math.max(60, 100 - conflicts.length * 12) : 96;
  return { timetable, conflicts, score, days: DAYS, slots: PERIOD_SLOTS };
}

module.exports = { generateTimetable, DAYS, PERIOD_SLOTS, SLOTS: PERIOD_SLOTS };
