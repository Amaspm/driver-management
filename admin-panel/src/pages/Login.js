import React, { useState } from 'react';
import { Form, Input, Button, Card, message } from 'antd';
import { UserOutlined, LockOutlined } from '@ant-design/icons';
import { authAPI } from '../services/api';

const Login = ({ onLogin }) => {
  const [loading, setLoading] = useState(false);

  const handleLogin = async (values) => {
    setLoading(true);
    try {
      const response = await authAPI.login(values.username, values.password);
      const token = response.data.token;
      
      localStorage.setItem('admin_token', token);
      message.success('Login berhasil');
      onLogin(token);
    } catch (error) {
      message.error('Login gagal. Periksa username dan password.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ 
      display: 'flex', 
      justifyContent: 'center', 
      alignItems: 'center', 
      minHeight: '100vh',
      background: '#f0f2f5'
    }}>
      <Card title="Admin Login" style={{ width: 400 }}>
        <Form onFinish={handleLogin}>
          <Form.Item
            name="username"
            rules={[{ required: true, message: 'Masukkan username!' }]}
          >
            <Input 
              prefix={<UserOutlined />} 
              placeholder="Username" 
            />
          </Form.Item>
          <Form.Item
            name="password"
            rules={[{ required: true, message: 'Masukkan password!' }]}
          >
            <Input.Password 
              prefix={<LockOutlined />} 
              placeholder="Password" 
            />
          </Form.Item>
          <Form.Item>
            <Button 
              type="primary" 
              htmlType="submit" 
              loading={loading}
              style={{ width: '100%' }}
            >
              Login
            </Button>
          </Form.Item>
        </Form>
      </Card>
    </div>
  );
};

export default Login;