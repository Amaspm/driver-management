import React, { useState } from 'react';
import { Form, Input, Button, Select, Card, message, Space } from 'antd';
import { UserAddOutlined, ArrowLeftOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';

const { Option } = Select;

const CreateDriver = () => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (values) => {
    setLoading(true);
    try {
      const response = await api.post('/auth/create-driver/', {
        email: values.email,
        password: values.password,
        status: values.status
      });
      
      message.success('Driver berhasil dibuat');
      form.resetFields();
      navigate('/drivers');
    } catch (error) {
      message.error('Gagal membuat driver: ' + (error.response?.data?.error || error.message));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: '24px' }}>
      <Space style={{ marginBottom: '24px' }}>
        <Button 
          icon={<ArrowLeftOutlined />} 
          onClick={() => navigate('/drivers')}
        >
          Kembali
        </Button>
        <h2 style={{ margin: 0 }}>Buat Akun Driver Baru</h2>
      </Space>

      <Card style={{ maxWidth: '600px' }}>
        <Form
          form={form}
          layout="vertical"
          onFinish={handleSubmit}
          autoComplete="off"
        >
          <Form.Item
            label="Email"
            name="email"
            rules={[
              { required: true, message: 'Email wajib diisi' },
              { type: 'email', message: 'Format email tidak valid' }
            ]}
          >
            <Input placeholder="driver@example.com" />
          </Form.Item>

          <Form.Item
            label="Password"
            name="password"
            rules={[
              { required: true, message: 'Password wajib diisi' },
              { min: 6, message: 'Password minimal 6 karakter' }
            ]}
          >
            <Input.Password placeholder="Masukkan password" />
          </Form.Item>

          <Form.Item
            label="Status Driver"
            name="status"
            rules={[{ required: true, message: 'Status wajib dipilih' }]}
          >
            <Select placeholder="Pilih status driver">
              <Option value="training">Training</Option>
              <Option value="pending">Pending Approval</Option>
              <Option value="active">Active</Option>
              <Option value="inactive">Inactive</Option>
              <Option value="suspended">Suspended</Option>
            </Select>
          </Form.Item>

          <Form.Item>
            <Button 
              type="primary" 
              htmlType="submit" 
              loading={loading}
              icon={<UserAddOutlined />}
              block
            >
              Buat Akun Driver
            </Button>
          </Form.Item>
        </Form>
      </Card>
    </div>
  );
};

export default CreateDriver;