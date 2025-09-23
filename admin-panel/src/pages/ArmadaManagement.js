import React, { useState, useEffect } from 'react';
import { Table, Button, Modal, Form, Input, Select, message, Space, Tag, InputNumber } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, EyeOutlined } from '@ant-design/icons';
import { driverAPI } from '../services/api';

const { Option } = Select;

const ArmadaManagement = () => {
  const [armadas, setArmadas] = useState([]);
  const [drivers, setDrivers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingArmada, setEditingArmada] = useState(null);
  const [form] = Form.useForm();

  useEffect(() => {
    fetchArmadas();
    fetchDrivers();
    fetchDriverArmadas();
  }, []);

  const fetchArmadas = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:8001/api/armada/', {
        headers: {
          'Authorization': `Token ${localStorage.getItem('admin_token')}`,
        },
      });
      const data = await response.json();
      setArmadas(data);
    } catch (error) {
      message.error('Gagal memuat data armada');
    } finally {
      setLoading(false);
    }
  };

  const fetchDrivers = async () => {
    try {
      const response = await driverAPI.getAll();
      setDrivers(response.data);
    } catch (error) {
      console.error('Error fetching drivers:', error);
    }
  };

  const handleSubmit = async (values) => {
    try {
      const url = editingArmada 
        ? `http://localhost:8001/api/armada/${editingArmada.id_armada}/`
        : 'http://localhost:8001/api/armada/';
      
      const method = editingArmada ? 'PUT' : 'POST';
      
      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Token ${localStorage.getItem('admin_token')}`,
        },
        body: JSON.stringify({
          ...values,
          tahun_pembuatan: new Date().toISOString(),
        }),
      });

      if (response.ok) {
        message.success(editingArmada ? 'Armada berhasil diupdate' : 'Armada berhasil ditambahkan');
        setModalVisible(false);
        form.resetFields();
        setEditingArmada(null);
        fetchArmadas();
      } else {
        throw new Error('Failed to save armada');
      }
    } catch (error) {
      message.error('Gagal menyimpan armada');
    }
  };

  const handleDelete = async (id) => {
    try {
      const response = await fetch(`http://localhost:8001/api/armada/${id}/`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Token ${localStorage.getItem('admin_token')}`,
        },
      });

      if (response.ok) {
        message.success('Armada berhasil dihapus');
        fetchArmadas();
      } else {
        throw new Error('Failed to delete armada');
      }
    } catch (error) {
      message.error('Gagal menghapus armada');
    }
  };

  const [driverArmadas, setDriverArmadas] = useState([]);

  const fetchDriverArmadas = async () => {
    try {
      const response = await fetch('http://localhost:8001/api/driver-armada/', {
        headers: {
          'Authorization': `Token ${localStorage.getItem('admin_token')}`,
        },
      });
      const data = await response.json();
      setDriverArmadas(data);
    } catch (error) {
      console.error('Error fetching driver-armada relations:', error);
    }
  };

  const getAssignedDriver = (armadaId) => {
    const assignment = driverArmadas.find(da => da.id_armada === armadaId);
    if (assignment) {
      const driver = drivers.find(d => d.id_driver === assignment.id_driver);
      return driver;
    }
    return null;
  };

  const columns = [
    {
      title: 'Nomor Polisi',
      dataIndex: 'nomor_polisi',
      key: 'nomor_polisi',
    },
    {
      title: 'Jenis Kendaraan',
      dataIndex: 'jenis_armada',
      key: 'jenis_armada',
    },
    {
      title: 'Warna',
      dataIndex: 'warna_armada',
      key: 'warna_armada',
    },
    {
      title: 'Kapasitas',
      dataIndex: 'kapasitas_muatan',
      key: 'kapasitas_muatan',
      render: (capacity) => `${capacity} kg`,
    },
    {
      title: 'Status',
      dataIndex: 'status',
      key: 'status',
      render: (status) => (
        <Tag color={status ? 'green' : 'red'}>
          {status ? 'Aktif' : 'Tidak Aktif'}
        </Tag>
      ),
    },
    {
      title: 'Driver',
      key: 'driver',
      render: (_, record) => {
        const assignedDriver = getAssignedDriver(record.id_armada);
        return assignedDriver ? (
          <Tag color="blue">{assignedDriver.nama}</Tag>
        ) : (
          <Tag color="orange">Belum Ada Driver</Tag>
        );
      },
    },
    {
      title: 'Aksi',
      key: 'action',
      render: (_, record) => (
        <Space>
          <Button 
            icon={<EditOutlined />}
            onClick={() => {
              setEditingArmada(record);
              form.setFieldsValue(record);
              setModalVisible(true);
            }}
          />
          <Button 
            icon={<DeleteOutlined />}
            danger
            onClick={() => handleDelete(record.id_armada)}
          />
        </Space>
      ),
    },
  ];

  return (
    <div>
      <div style={{ marginBottom: 16 }}>
        <Button 
          type="primary" 
          icon={<PlusOutlined />}
          onClick={() => {
            setEditingArmada(null);
            form.resetFields();
            setModalVisible(true);
          }}
        >
          Tambah Armada
        </Button>
      </div>

      <Table
        columns={columns}
        dataSource={armadas}
        rowKey="id_armada"
        loading={loading}
      />

      <Modal
        title={editingArmada ? 'Edit Armada' : 'Tambah Armada'}
        open={modalVisible}
        onCancel={() => {
          setModalVisible(false);
          setEditingArmada(null);
          form.resetFields();
        }}
        footer={null}
      >
        <Form form={form} onFinish={handleSubmit} layout="vertical">
          <Form.Item name="nomor_polisi" label="Nomor Polisi" rules={[{ required: true }]}>
            <Input placeholder="B 1234 ABC" />
          </Form.Item>
          
          <Form.Item name="jenis_armada" label="Jenis Kendaraan" rules={[{ required: true }]}>
            <Select placeholder="Pilih jenis kendaraan">
              <Option value="Motor">Motor</Option>
              <Option value="Mobil">Mobil</Option>
              <Option value="Truk">Truk</Option>
              <Option value="Pick Up">Pick Up</Option>
            </Select>
          </Form.Item>
          
          <Form.Item name="warna_armada" label="Warna" rules={[{ required: true }]}>
            <Input placeholder="Merah" />
          </Form.Item>
          
          <Form.Item name="kapasitas_muatan" label="Kapasitas Muatan (kg)" rules={[{ required: true }]}>
            <InputNumber min={1} style={{ width: '100%' }} placeholder="1000" />
          </Form.Item>
          
          <Form.Item name="id_stnk" label="ID STNK" rules={[{ required: true }]}>
            <Input placeholder="STNK123456" />
          </Form.Item>
          
          <Form.Item name="id_bpkb" label="ID BPKB" rules={[{ required: true }]}>
            <Input placeholder="BPKB123456" />
          </Form.Item>
          
          <Form.Item name="status" label="Status" valuePropName="checked" initialValue={true}>
            <Select>
              <Option value={true}>Aktif</Option>
              <Option value={false}>Tidak Aktif</Option>
            </Select>
          </Form.Item>

          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit">
                {editingArmada ? 'Update' : 'Simpan'}
              </Button>
              <Button onClick={() => setModalVisible(false)}>
                Batal
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default ArmadaManagement;