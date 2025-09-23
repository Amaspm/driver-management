import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const Login = () => {
  const [formData, setFormData] = useState({
    username: '', // akan digunakan sebagai email
    password: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const navigate = useNavigate();

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    
    if (!formData.username.includes('@')) {
      setError('Format email tidak valid');
      setLoading(false);
      return;
    }
    
    console.log('Attempting login with:', formData);
    
    try {
      const response = await axios.post('http://localhost:8000/api/auth/login/', formData, {
        headers: {
          'Content-Type': 'application/json',
        },
        timeout: 10000
      });
      console.log('Login response:', response.data);
      
      if (response.data.token) {
        localStorage.setItem('token', response.data.token);
        localStorage.setItem('user', JSON.stringify(response.data));
        console.log('Login successful, redirecting to dashboard');
        window.location.href = '/dashboard';
      } else {
        setError('Login gagal: Token tidak diterima');
      }
    } catch (error) {
      console.error('Login error:', error);
      console.error('Error response:', error.response?.data);
      console.error('Error status:', error.response?.status);
      
      if (error.code === 'ECONNABORTED') {
        setError('Koneksi timeout. Periksa koneksi internet Anda.');
      } else if (error.response?.status === 0 || !error.response) {
        setError('Tidak dapat terhubung ke server. Pastikan backend berjalan di port 8000.');
      } else {
        const errorMsg = error.response?.data?.error || 'Login gagal. Periksa email dan password Anda.';
        setError(errorMsg);
      }
    } finally {
      setLoading(false);
    }
  };

  const handleRegisterClick = (e) => {
    e.preventDefault();
    setShowModal(true);
  };

  return (
    <div className="app-container">
      <div className="header">
        <h1>Login</h1>
        <div className="header-actions">
          <a href="#" className="help-center">Help Center</a>
          <span>⋮</span>
        </div>
      </div>

      <div className="container">
        <div className="phone-image">
          <img src="/assets/images/Rectangle 299.png" alt="Phone" />
        </div>

        <h2 className="title">Login</h2>
        
        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Email</label>
            <input
              type="email"
              name="username"
              className="form-control"
              placeholder="driver@example.com"
              value={formData.username}
              onChange={handleChange}
              required
            />
          </div>

          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              name="password"
              className="form-control"
              value={formData.password}
              onChange={handleChange}
              required
            />
          </div>

          <button type="submit" className="btn btn-primary" disabled={loading}>
            {loading ? 'Loading...' : 'Login'}
          </button>
        </form>

        <div className="text-center" style={{marginTop: '20px'}}>
          <div style={{background: '#f8f9fa', padding: '15px', borderRadius: '8px', fontSize: '12px'}}>
            <strong>Demo Driver Accounts:</strong><br/>
            Email: driver1@example.com | Password: driver123<br/>
            Email: driver2@example.com | Password: driver123
          </div>
        </div>
        
        <div className="text-center" style={{marginTop: '20px'}}>
          Belum punya akun? <a href="#" onClick={handleRegisterClick} className="link">Daftar di sini</a>
        </div>
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h3>Registrasi Driver</h3>
            <p>Untuk mendaftar sebagai driver, silakan gunakan aplikasi mobile Driver Management yang tersedia di Play Store atau App Store.</p>
            <button className="modal-btn" onClick={() => setShowModal(false)}>
              Mengerti
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default Login;