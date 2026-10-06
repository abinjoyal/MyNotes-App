import 'package:flutter_test/flutter_test.dart';
import 'package:notes/features/tasks/utils/task_markdown_utils.dart';

void main() {
  group('TaskMarkdownUtils Tests', () {
    test('parseTasksFromContent correctly parses Markdown check items', () {
      const content = '- [ ] Buy groceries #personal\n- [x] Complete report';
      final tasks = TaskMarkdownUtils.parseTasksFromContent(content);

      expect(tasks.length, equals(2));
      expect(tasks[0].text, equals('Buy groceries'));
      expect(tasks[0].isCompleted, isFalse);
      expect(tasks[0].tag, equals('personal'));
      expect(tasks[1].text, equals('Complete report'));
      expect(tasks[1].isCompleted, isTrue);
    });

    test('toggleTaskInContent toggles checkbox state', () {
      const content = '- [ ] Task 1';
      final updated = TaskMarkdownUtils.toggleTaskInContent(content, 0, false);

      expect(updated, equals('- [x] Task 1'));
    });

    test('addNewTaskToContent appends new task item', () {
      const content = '- [ ] Task 1';
      final updated = TaskMarkdownUtils.addNewTaskToContent(content, 'Task 2');

      expect(updated, equals('- [ ] Task 1\n- [ ] Task 2'));
    });

    test('deleteTaskFromContent removes specified task item', () {
      const content = '- [ ] Task 1\n- [ ] Task 2';
      final updated = TaskMarkdownUtils.deleteTaskFromContent(content, 0);

      expect(updated, equals('- [ ] Task 2'));
    });
  });
}
