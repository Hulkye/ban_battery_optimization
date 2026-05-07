import 'dart:io';

import 'package:ban_battery_optimization/ban_battery_optimization.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ban Battery Optimization Example',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  BatteryRestrictionSnapshot? _snapshot;
  String _status = '未执行';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshSnapshot();
  }

  Future<void> _runAction(
    String label,
    Future<void> Function() action,
  ) async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _status = '$label 执行中...';
    });

    try {
      await action();
      await _refreshSnapshot();
    } catch (error) {
      setState(() {
        _status = '$label 失败：$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _refreshSnapshot() async {
    final snapshot = await BanBatteryOptimization.getBatteryRestrictionSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot = snapshot;
      _status = '最近刷新：${DateTime.now()}';
    });
  }

  Future<void> _checkStatus() async {
    await _runAction('检测状态', () async {
      final enabled = await BanBatteryOptimization.isBatteryOptimizationEnabled();
      setState(() {
        _status = enabled ? '当前仍受电池优化限制' : '当前已加入白名单';
      });
    });
  }

  Future<void> _requestDisableOptimization() async {
    await _runAction('申请白名单', () async {
      final outcome =
          await BanBatteryOptimization.ensureOptimizationDisabledDetailed();
      setState(() {
        _status = '申请结果：${outcome.status.name}';
      });
    });
  }

  Future<void> _openBatterySettings() async {
    await _runAction('打开系统设置', () async {
      await BanBatteryOptimization.openBatteryOptimizationSettings();
      setState(() {
        _status = '已尝试打开系统电池优化设置';
      });
    });
  }

  Future<void> _openAutoStartSettings() async {
    await _runAction('打开厂商设置', () async {
      final opened = await BanBatteryOptimization.openAutoStartSettings();
      setState(() {
        _status = opened ? '已尝试打开厂商自启动设置' : '当前设备无可用厂商设置页';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Scaffold(
      appBar: AppBar(title: const Text('ban_battery_optimization 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('运行平台：${Platform.operatingSystem}'),
                  const SizedBox(height: 8),
                  Text('状态：$_status'),
                  const SizedBox(height: 8),
                  Text('支持插件能力：${snapshot?.isSupported ?? false}'),
                  Text('厂商：${snapshot?.manufacturer ?? 'unknown'}'),
                  Text('Android SDK：${snapshot?.androidSdkInt?.toString() ?? '-'}'),
                  Text(
                    '受电池优化限制：${snapshot == null ? '-' : snapshot.isBatteryOptimizationEnabled}',
                  ),
                  Text(
                    '省电模式开启：${snapshot == null ? '-' : snapshot.isPowerSaveModeOn}',
                  ),
                  Text(
                    '可打开厂商设置页：${snapshot == null ? '-' : snapshot.canOpenAutoStartSettings}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _refreshSnapshot,
            child: const Text('刷新快照'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _checkStatus,
            child: const Text('检测是否受限制'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _requestDisableOptimization,
            child: const Text('申请加入白名单'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _openBatterySettings,
            child: const Text('打开系统电池优化设置'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _openAutoStartSettings,
            child: const Text('打开厂商自启动设置'),
          ),
        ],
      ),
    );
  }
}
