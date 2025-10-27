import 'package:flutter/material.dart';

class DynamicTable extends StatelessWidget {
  final List<String> columns;
  final List<String> columnLabels;
  final List<Map<String, dynamic>> data;
  final void Function(Map<String, dynamic> rowData) onEdit;

  const DynamicTable({
    super.key,
    required this.columns,
    required this.data,
    required this.onEdit,
    required this.columnLabels,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            // ✅ Force table to take full width of its parent
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                const Color.fromARGB(255, 218, 209, 235),
              ),
              columnSpacing: 16,
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: const Color.fromARGB(255, 218, 209, 235),
                  width: 0.5,
                ),
                top: BorderSide.none,
                bottom: BorderSide(
                  color: const Color.fromARGB(255, 218, 209, 235),
                  width: 0.5,
                ),
                left: BorderSide.none,
                right: BorderSide.none,
                verticalInside: BorderSide.none,
              ),
              columns: [
                ...columnLabels.map(
                  (col) => DataColumn(
                    label: Text(
                      col,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const DataColumn(label: Text('Actions')),
              ],
              rows: List<DataRow>.generate(data.length, (index) {
                final row = data[index];
                return DataRow(
                  // ✅ Alternate color for even rows
                  color: WidgetStateProperty.resolveWith<Color?>((
                    Set<MaterialState> states,
                  ) {
                    if (index % 2 == 0) {
                      return const Color.fromARGB(
                        255,
                        235,
                        232,
                        246,
                      ); // light lavender
                    }
                    return null; // use default background
                  }),
                  cells: [
                    ...columns.map(
                      (key) => DataCell(
                        Text(
                          row[key]?.toString() ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            218,
                            209,
                            235,
                          ),
                        ),
                        onPressed: () => onEdit(row),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
