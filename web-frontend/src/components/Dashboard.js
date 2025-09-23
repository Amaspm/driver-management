import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';

const Dashboard = () => {
  const [user, setUser] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const token = localStorage.getItem('token');
    const userData = localStorage.getItem('user');
    
    if (!token || !userData) {
      window.location.href = '/login';
      return;
    }

    try {
      setUser(JSON.parse(userData));
    } catch (error) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
  }, [navigate]);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    window.location.href = '/login';
  };

  const handleMenuClick = (menu) => {
    alert(`Fitur ${menu} dalam pengembangan`);
  };

  if (!user) {
    return (
      <div className="app-container">
        <div className="header">
          <h1 style={{color: '#dc3545'}}>Dashboard Driver</h1>
        </div>
        <div className="container">
          <div className="text-center">Loading...</div>
        </div>
      </div>
    );
  }

  const getStatusColor = (status) => {
    switch (status?.toLowerCase()) {
      case 'active': return '#28a745';
      case 'suspended': return '#dc3545';
      case 'pending': return '#ffc107';
      default: return '#6c757d';
    }
  };

  const getStatusTextColor = (status) => {
    return status?.toLowerCase() === 'pending' ? '#212529' : 'white';
  };

  return (
    <div className="app-container">
      <div className="header" style={{background: '#dc3545', color: 'white', padding: '20px'}}>
        <h1 style={{color: 'white', margin: 0}}>Dashboard Driver</h1>
        <div className="header-actions">
          <button 
            onClick={handleLogout} 
            style={{
              background: 'rgba(255,255,255,0.2)', 
              color: 'white', 
              border: '1px solid rgba(255,255,255,0.3)',
              padding: '8px 16px', 
              borderRadius: '4px',
              cursor: 'pointer'
            }}
          >
            Logout
          </button>
        </div>
      </div>

      <div style={{padding: '20px', background: '#f8f9fa', minHeight: 'calc(100vh - 80px)'}}>
        {/* Welcome Card */}
        <div style={{
          background: 'white',
          padding: '20px',
          borderRadius: '12px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
          marginBottom: '20px'
        }}>
          <h2 style={{color: '#dc3545', marginBottom: '8px'}}>Selamat Datang!</h2>
          <h3 style={{color: '#495057', marginBottom: '12px'}}>
            {user.driver?.name || user.username}
          </h3>
          <div style={{display: 'flex', alignItems: 'center', gap: '8px'}}>
            <span style={{color: '#6c757d'}}>Status:</span>
            <span style={{
              background: getStatusColor(user.driver?.status),
              color: getStatusTextColor(user.driver?.status),
              padding: '4px 12px',
              borderRadius: '20px',
              fontSize: '12px',
              fontWeight: '600',
              textTransform: 'uppercase'
            }}>
              {user.driver?.status || 'unknown'}
            </span>
          </div>
        </div>

        {/* Menu Grid */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
          gap: '15px'
        }}>
          {[
            {icon: '🚚', title: 'Delivery Orders', subtitle: 'Lihat tugas pengiriman', color: '#007bff'},
            {icon: '📋', title: 'Riwayat', subtitle: 'Riwayat perjalanan', color: '#28a745'},
            {icon: '💰', title: 'Pembayaran', subtitle: 'Fee dan pembayaran', color: '#ffc107'},
            {icon: '👤', title: 'Profil', subtitle: 'Kelola profil Anda', color: '#6c757d'}
          ].map((menu, index) => (
            <div 
              key={index}
              onClick={() => handleMenuClick(menu.title)}
              style={{
                background: 'white',
                padding: '20px',
                borderRadius: '12px',
                boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                cursor: 'pointer',
                textAlign: 'center',
                transition: 'transform 0.2s',
                ':hover': {transform: 'translateY(-2px)'}
              }}
            >
              <div style={{
                background: `${menu.color}20`,
                width: '60px',
                height: '60px',
                borderRadius: '50%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 12px',
                fontSize: '24px'
              }}>
                {menu.icon}
              </div>
              <h4 style={{color: '#495057', marginBottom: '4px'}}>{menu.title}</h4>
              <p style={{color: '#6c757d', fontSize: '12px', margin: 0}}>{menu.subtitle}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;