import axios from 'axios';

const API_BASE_URL = 'http://localhost:8001/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token');
  if (token) {
    config.headers.Authorization = `Token ${token}`;
  }
  return config;
});

// Auth API
export const authAPI = {
  login: (username, password) => api.post('/auth/admin-login/', { username, password }),
  getProfile: () => api.get('/auth/user/'),
};

// Driver API
export const driverAPI = {
  getAll: () => api.get('/drivers/'),
  getById: (id) => api.get(`/drivers/${id}/`),
  updateStatus: (id, status, reason = null) => api.patch(`/drivers/${id}/`, { 
    status, 
    alasan_penolakan: reason 
  }),
  delete: (id) => {
    console.log(`Deleting driver with ID: ${id}`);
    return api.delete(`/drivers/${id}/`);
  },
  cleanupUsers: () => api.post('/admin/cleanup-users/'),
  checkSync: () => api.get('/admin/check-sync/'),
  bulkActivate: (ids) => api.post('/drivers/bulk_activate/', { driver_ids: ids }),
  bulkSuspend: (ids) => api.post('/drivers/bulk_suspend/', { driver_ids: ids }),
  bulkAccept: (ids) => api.post('/drivers/bulk_accept/', { driver_ids: ids }),
};

// Training API
export const trainingAPI = {
  getModules: () => api.get('/training-modules/'),
  getModule: (id) => api.get(`/training-modules/${id}/`),
  createModule: (data) => api.post('/training-modules/', data),
  updateModule: (id, data) => api.put(`/training-modules/${id}/`, data),
  deleteModule: (id) => api.delete(`/training-modules/${id}/`),
  
  getContents: (moduleId) => api.get(`/training-contents/?module_id=${moduleId}`),
  createContent: (data) => api.post('/training-contents/', data),
  updateContent: (id, data) => api.put(`/training-contents/${id}/`, data),
  deleteContent: (id) => api.delete(`/training-contents/${id}/`),
  
  getQuizzes: (moduleId) => api.get(`/training-quizzes/?module_id=${moduleId}`),
  createQuiz: (data) => api.post('/training-quizzes/', data),
  updateQuiz: (id, data) => api.put(`/training-quizzes/${id}/`, data),
  deleteQuiz: (id) => api.delete(`/training-quizzes/${id}/`),
};

export default api;