import React from 'react';
import { useNavigate } from 'react-router-dom';

const Register = () => {
  const navigate = useNavigate();

  React.useEffect(() => {
    // Redirect to login immediately
    navigate('/login');
  }, [navigate]);

  return null;
};

export default Register;