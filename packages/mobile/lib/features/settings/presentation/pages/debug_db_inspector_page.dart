import 'package:drift/drift.dart' show QueryRow, TableInfo;
import 'package:flutter/material.dart';

import 'package:expense_tracker/core/database/app_database.dart';

const Set<String> _internalTables = {'expense_fts'};
const int _rowLimit = 200;

class DebugDbInspectorPage extends StatelessWidget {
  const DebugDbInspectorPage({required this.database, super.key});

  final AppDatabase database;

  Widget _buildTableTile(
    BuildContext context,
    List<TableInfo<dynamic, dynamic>> tables,
    int i,
  ) {
    final table = tables[i];

    return ListTile(
      leading: const Icon(Icons.table_chart),
      title: Text(table.actualTableName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openTable(context, table),
    );
  }

  void _openTable(BuildContext context, TableInfo<dynamic, dynamic> table) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _TableRowsPage(database: database, table: table),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tables = database.allTables
        .where((t) => !_internalTables.contains(t.actualTableName))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Inspector'),
        leading: const Icon(Icons.bug_report),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: ListView.separated(
        itemCount: tables.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) => _buildTableTile(context, tables, i),
      ),
    );
  }
}

class _TableRowsPage extends StatefulWidget {
  const _TableRowsPage({required this.database, required this.table});

  final AppDatabase database;
  final TableInfo<dynamic, dynamic> table;

  @override
  State<_TableRowsPage> createState() => _TableRowsPageState();
}

class _TableRowsPageState extends State<_TableRowsPage> {
  @override
  void initState() {
    super.initState();
    _rowsFuture = _load();
  }

  Future<List<QueryRow>>? _rowsFuture;

  Future<List<QueryRow>> _load() {
    return widget.database
        .customSelect(
          'SELECT * FROM `${widget.table.actualTableName}` LIMIT $_rowLimit',
        )
        .get();
  }

  void _refresh() {
    setState(() {
      _rowsFuture = _load();
    });
  }

  Widget _buildFutureBody(
    ThemeData theme,
    AsyncSnapshot<List<QueryRow>> snapshot,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return _buildError(snapshot, theme);
    }
    final rows = snapshot.data ?? const <QueryRow>[];
    if (rows.isEmpty) {
      return const Center(child: Text('No rows'));
    }

    return Column(
      children: [
        _buildRowCountHeader(rows, theme),
        Expanded(child: _buildRowsList(rows, theme)),
      ],
    );
  }

  Widget _buildError(AsyncSnapshot<List<QueryRow>> snapshot, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Error: ${snapshot.error}',
        style: TextStyle(color: theme.colorScheme.error),
      ),
    );
  }

  Widget _buildRowCountHeader(List<QueryRow> rows, ThemeData theme) {
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Showing ${rows.length} rows'
        '${rows.length == _rowLimit ? ' (capped at $_rowLimit)' : ''}',
        style: theme.textTheme.labelMedium,
      ),
    );
  }

  Widget _buildRowsList(List<QueryRow> rows, ThemeData theme) {
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) => _buildRowTile(rows[i].data, i, theme),
    );
  }

  Widget _buildRowTile(Map<String, dynamic> entry, int i, ThemeData theme) {
    return ExpansionTile(
      title: Text('Row ${i + 1}'),
      subtitle: Text(
        _preview(entry),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: entry.entries.map((e) => _buildFieldRow(e)).toList(),
    );
  }

  Widget _buildFieldRow(MapEntry<String, dynamic> field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              field.key,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(_truncate('${field.value}'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.table.actualTableName),
        leading: const Icon(Icons.bug_report),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<QueryRow>>(
        future: _rowsFuture,
        builder: (context, snapshot) => _buildFutureBody(theme, snapshot),
      ),
    );
  }
}

String _preview(Map<String, dynamic> row) {
  return row.entries
      .take(3)
      .map((e) => '${e.key}=${_truncate('${e.value}')}')
      .join(' • ');
}

String _truncate(String value) {
  return value.length > 80 ? '${value.substring(0, 80)}…' : value;
}
