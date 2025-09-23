import React, { useState, useEffect } from 'react';
import { Card, Row, Col, Statistic, Table, Tag } from 'antd';
import { UserOutlined, CheckCircleOutlined, ClockCircleOutlined, StopOutlined } from '@ant-design/icons';
import { driverAPI } from '../services/api';

const Dashboard = () => {
  const [stats, setStats] = useState({
    total: 0,
    active: 0,
    pending: 0,
    training: 0,
    suspended: 0
  });
  const [recentDrivers, setRecentDrivers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const response = await driverAPI.getAll();
      const drivers = response.data;
      
      const statsData = {
        total: drivers.length,
        active: drivers.filter(d => d.status === 'active').length,
        pending: drivers.filter(d => d.status === 'pending').length,
        training: drivers.filter(d => d.status === 'training').length,
        suspended: drivers.filter(d => d.status === 'suspended').length
      };
      
      setStats(statsData);
      setRecentDrivers(drivers.slice(0, 10));
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      active: 'green',
      pending: 'orange',
      training: 'blue',
      suspended: 'red',
      rejected: 'red'
    };
    return colors[status] || 'default';
  };

  const columns = [
    {
      title: 'Nama',
      dataIndex: 'nama',
      key: 'nama',
    },
    {
      title: 'Email',
      dataIndex: 'email',
      key: 'email',
    },
    {
      title: 'No HP',
      dataIndex: 'no_hp',
      key: 'no_hp',
    },
    {
      title: 'Status',
      dataIndex: 'status',
      key: 'status',
      render: (status) => (
        <Tag color={getStatusColor(status)}>
          {status.toUpperCase()}
        </Tag>
      ),
    },
    {
      title: 'Tanggal Daftar',
      dataIndex: 'wkt_daftar',
      key: 'wkt_daftar',
      render: (date) => new Date(date).toLocaleDateString('id-ID'),
    },
  ];

  return (
    <div>
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={6}>
          <Card>
            <Statistic
              title="Total Driver"
              value={stats.total}
              prefix={<UserOutlined />}
              loading={loading}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="Active"
              value={stats.active}
              prefix={<CheckCircleOutlined />}
              valueStyle={{ color: '#3f8600' }}
              loading={loading}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="Pending"
              value={stats.pending}
              prefix={<ClockCircleOutlined />}
              valueStyle={{ color: '#cf1322' }}
              loading={loading}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="Training"
              value={stats.training}
              prefix={<ClockCircleOutlined />}
              valueStyle={{ color: '#1890ff' }}
              loading={loading}
            />
          </Card>
        </Col>
      </Row>

      <Card title="Driver Terbaru" style={{ marginTop: 16 }}>
        <Table
          columns={columns}
          dataSource={recentDrivers}
          rowKey="id_driver"
          loading={loading}
          pagination={false}
        />
      </Card>
    </div>
  );
};

export default Dashboard;