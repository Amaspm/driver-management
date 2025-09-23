import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Layout, Menu, Button } from 'antd';
import {
  DashboardOutlined,
  UserOutlined,
  BookOutlined,
  CarOutlined,
  LogoutOutlined,
} from '@ant-design/icons';
import { Link } from 'react-router-dom';

import Dashboard from './pages/Dashboard';
import DriverManagement from './pages/DriverManagement';
import TrainingManagement from './pages/TrainingManagement';
import ArmadaManagement from './pages/ArmadaManagement';
import CreateDriver from './pages/CreateDriver';
import Login from './pages/Login';

const { Header, Content, Sider } = Layout;

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('admin_token');
    if (token) {
      setIsAuthenticated(true);
    }
  }, []);

  const handleLogin = (token) => {
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    setIsAuthenticated(false);
  };

  if (!isAuthenticated) {
    return <Login onLogin={handleLogin} />;
  }

  return (
    <Router>
      <Layout style={{ minHeight: '100vh' }}>
        <Sider>
          <div style={{ 
            height: 32, 
            margin: 16, 
            color: 'white', 
            fontSize: '16px',
            fontWeight: 'bold'
          }}>
            Driver Admin
          </div>
          <Menu theme="dark" mode="inline" defaultSelectedKeys={['1']}>
            <Menu.Item key="1" icon={<DashboardOutlined />}>
              <Link to="/">Dashboard</Link>
            </Menu.Item>
            <Menu.Item key="2" icon={<UserOutlined />}>
              <Link to="/drivers">Driver Management</Link>
            </Menu.Item>
            <Menu.Item key="3" icon={<BookOutlined />}>
              <Link to="/training">Training Management</Link>
            </Menu.Item>
            <Menu.Item key="4" icon={<CarOutlined />}>
              <Link to="/armada">Armada Management</Link>
            </Menu.Item>
          </Menu>
        </Sider>

        <Layout>
          <Header style={{ background: '#fff', padding: '0 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <h2 style={{ margin: 0 }}>Driver Management System</h2>
            <Button icon={<LogoutOutlined />} onClick={handleLogout}>
              Logout
            </Button>
          </Header>
          <Content style={{ margin: '16px' }}>
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/drivers" element={<DriverManagement />} />
              <Route path="/drivers/create" element={<CreateDriver />} />
              <Route path="/training" element={<TrainingManagement />} />
              <Route path="/armada" element={<ArmadaManagement />} />
            </Routes>
          </Content>
        </Layout>
      </Layout>
    </Router>
  );
}

export default App;