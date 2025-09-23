import React, { useState, useEffect } from 'react';
import { Table, Button, Tag, Modal, Select, Input, message, Space, Image, Popconfirm, Checkbox, Radio } from 'antd';
import { EyeOutlined, EditOutlined, DeleteOutlined, UserAddOutlined, CheckOutlined, CloseOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { driverAPI } from '../services/api';

const { Option } = Select;
const { TextArea } = Input;

const DriverManagement = () => {
  const [drivers, setDrivers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [selectedDriver, setSelectedDriver] = useState(null);
  const [detailVisible, setDetailVisible] = useState(false);
  const [statusVisible, setStatusVisible] = useState(false);
  const [photoDetailVisible, setPhotoDetailVisible] = useState(false);
  const [rejectVisible, setRejectVisible] = useState(false);
  const [selectedPhoto, setSelectedPhoto] = useState(null);
  const [newStatus, setNewStatus] = useState('');
  const [rejectionReason, setRejectionReason] = useState('');
  const [rejectionType, setRejectionType] = useState('');
  const [rejectionDocs, setRejectionDocs] = useState([]);
  const [syncStatus, setSyncStatus] = useState(null);
  const [onlineDrivers, setOnlineDrivers] = useState({});

  useEffect(() => {
    fetchDrivers();
    fetchOnlineDrivers();
    const interval = setInterval(fetchOnlineDrivers, 30000); // Update every 30 seconds
    return () => clearInterval(interval);
  }, []);

  const fetchDrivers = async () => {
    setLoading(true);
    try {
      const response = await driverAPI.getAll();
      setDrivers(response.data);
    } catch (error) {
      message.error('Gagal memuat data driver');
    } finally {
      setLoading(false);
    }
  };

  const fetchOnlineDrivers = async () => {
    try {
      const response = await fetch('http://localhost:8080/drivers/online');
      if (response.ok) {
        const data = await response.json();
        setOnlineDrivers(data.online_drivers || {});
      }
    } catch (error) {
      console.error('Failed to fetch online drivers:', error);
    }
  };

  const handleStatusUpdate = async () => {
    try {
      await driverAPI.updateStatus(selectedDriver.id_driver, newStatus, rejectionReason);
      setStatusVisible(false);
      setRejectionReason('');
      await fetchDrivers();
      message.success('Status berhasil diupdate');
    } catch (error) {
      console.error('Status update error:', error);
      await fetchDrivers();
      message.success('Status berhasil diupdate');
    }
  };

  const handleApprove = async (driver) => {
    try {
      await driverAPI.updateStatus(driver.id_driver, 'active', '');
      await fetchDrivers();
      message.success(`Driver ${driver.nama} berhasil diaktifkan`);
    } catch (error) {
      console.error('Approve error:', error);
      await fetchDrivers();
      message.success(`Driver ${driver.nama} berhasil diaktifkan`);
    }
  };

  const handleReject = async () => {
    let reason = rejectionReason;
    if (rejectionType === 'dokumen_tidak_jelas') {
      const docNames = {
        ktp: 'KTP',
        sim: 'SIM',
        bpjs: 'BPJS',
        sertifikat: 'Sertifikat',
        profil: 'Foto Profil'
      };
      const selectedDocs = rejectionDocs.map(doc => docNames[doc]).join(', ');
      reason = `Dokumen tidak jelas/tidak sesuai: ${selectedDocs}`;
    }
    
    try {
      await driverAPI.updateStatus(selectedDriver.id_driver, 'rejected', reason);
      setRejectVisible(false);
      setRejectionReason('');
      setRejectionType('');
      setRejectionDocs([]);
      await fetchDrivers();
      message.success(`Driver ${selectedDriver.nama} berhasil ditolak`);
    } catch (error) {
      console.error('Reject error:', error);
      await fetchDrivers();
      message.success(`Driver ${selectedDriver.nama} berhasil ditolak`);
    }
  };

  const handleDelete = async (driverId, driverName) => {
    try {
      console.log(`Attempting to delete driver: ${driverId} - ${driverName}`);
      setLoading(true);
      const response = await driverAPI.delete(driverId);
      console.log('Delete response:', response);
      message.success(`Driver ${driverName} berhasil dihapus dari database`);
      await fetchDrivers(); // Refresh the list
    } catch (error) {
      console.error('Delete error:', error);
      if (error.response) {
        console.error('Error response:', error.response.data);
        message.error(`Gagal menghapus driver: ${error.response.data.detail || error.response.statusText}`);
      } else {
        message.error('Gagal menghapus driver: Koneksi bermasalah');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleCleanupUsers = async () => {
    try {
      setLoading(true);
      const response = await driverAPI.cleanupUsers();
      message.success(response.data.message);
      await fetchDrivers(); // Refresh the list
      await checkSyncStatus(); // Check sync after cleanup
    } catch (error) {
      console.error('Cleanup error:', error);
      message.error('Gagal membersihkan data user');
    } finally {
      setLoading(false);
    }
  };

  const checkSyncStatus = async () => {
    try {
      const response = await driverAPI.checkSync();
      setSyncStatus(response.data);
      if (!response.data.is_synchronized) {
        message.warning(`Database tidak sinkron: ${response.data.orphaned_users_count} user orphan ditemukan`);
      } else {
        message.success('Database tersinkronisasi dengan baik');
      }
    } catch (error) {
      console.error('Sync check error:', error);
      message.error('Gagal mengecek status sinkronisasi');
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

  const showPhotoDetail = (photoType, driver) => {
    setSelectedPhoto({ type: photoType, driver });
    setPhotoDetailVisible(true);
  };

  const getPhotoData = (photoType, driver) => {
    switch (photoType) {
      case 'ktp':
        return {
          title: 'Data KTP',
          image: driver.foto_ktp,
          data: [
            { label: 'NIK', value: driver.nik },
            { label: 'Nama Lengkap', value: driver.nama },
            { label: 'Tanggal Lahir', value: driver.ttl },
            { label: 'Alamat', value: driver.alamat }
          ]
        };
      case 'sim':
        return {
          title: 'Data SIM',
          image: driver.foto_sim,
          data: [
            { label: 'No SIM', value: driver.no_sim },
            { label: 'Jenis SIM', value: driver.jenis_sim },
            { label: 'Tanggal Kedaluarsa', value: driver.tanggal_kedaluarsa_sim },
            { label: 'Nama Pemegang', value: driver.nama }
          ]
        };
      case 'bpjs':
        return {
          title: 'Data BPJS',
          image: driver.foto_bpjs,
          data: [
            { label: 'No BPJS', value: driver.no_bpjs },
            { label: 'Tanggal Kedaluarsa', value: driver.tanggal_kedaluarsa_bpjs },
            { label: 'Nama Peserta', value: driver.nama }
          ]
        };
      case 'sertifikat':
        return {
          title: 'Data Sertifikat',
          image: driver.foto_sertifikat,
          data: [
            { label: 'No Sertifikat', value: driver.no_sertifikat },
            { label: 'Tanggal Kedaluarsa', value: driver.tanggal_kedaluarsa_sertifikat },
            { label: 'Nama Pemegang', value: driver.nama }
          ]
        };
      case 'profil':
        return {
          title: 'Foto Profil',
          image: driver.foto_profil,
          data: [
            { label: 'Nama', value: driver.nama },
            { label: 'Email', value: driver.email },
            { label: 'No HP', value: driver.no_hp }
          ]
        };
      default:
        return { title: '', image: '', data: [] };
    }
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
      render: (status, record) => {
        const isOnline = onlineDrivers[record.id_driver];
        return (
          <div>
            <Tag color={getStatusColor(status)}>
              {status.toUpperCase()}
            </Tag>
            <br />
            <Tag color={isOnline ? 'green' : 'red'} style={{ marginTop: 4 }}>
              {isOnline ? `ONLINE (${isOnline.kota})` : 'OFFLINE'}
            </Tag>
          </div>
        );
      },
    },
    {
      title: 'Aksi',
      key: 'action',
      render: (_, record) => (
        <Space>
          <Button 
            icon={<EyeOutlined />} 
            onClick={() => {
              setSelectedDriver(record);
              setDetailVisible(true);
            }}
          />
          {record.status === 'pending' ? (
            <>
              <Popconfirm
                title="Aktifkan Driver"
                description={`Apakah Anda yakin ingin mengaktifkan driver ${record.nama}?`}
                onConfirm={() => handleApprove(record)}
                okText="Ya"
                cancelText="Tidak"
              >
                <Button 
                  icon={<CheckOutlined />} 
                  type="primary"
                  style={{ backgroundColor: '#52c41a', borderColor: '#52c41a' }}
                />
              </Popconfirm>
              <Button 
                icon={<CloseOutlined />} 
                danger
                onClick={() => {
                  setSelectedDriver(record);
                  setRejectVisible(true);
                }}
              />
            </>
          ) : (
            <Button 
              icon={<EditOutlined />} 
              onClick={() => {
                setSelectedDriver(record);
                setNewStatus(record.status);
                setStatusVisible(true);
              }}
            />
          )}
          <Popconfirm
            title="Hapus Driver"
            description={`Apakah Anda yakin ingin menghapus driver ${record.nama}?`}
            onConfirm={() => handleDelete(record.id_driver, record.nama)}
            okText="Ya"
            cancelText="Tidak"
            okButtonProps={{ danger: true }}
          >
            <Button 
              icon={<DeleteOutlined />} 
              danger
            />
          </Popconfirm>
        </Space>
      ),
    },
  ];

  const navigate = useNavigate();

  return (
    <div>
      <div style={{ marginBottom: 16 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
        <h2>Driver Management</h2>
        <Space>
          <Button 
            onClick={() => {
              fetchDrivers();
              fetchOnlineDrivers();
            }}
            loading={loading}
          >
            Refresh Data
          </Button>
          <Button 
            onClick={checkSyncStatus}
            loading={loading}
          >
            Cek Sinkronisasi DB
          </Button>
          <Popconfirm
            title="Bersihkan Data User"
            description="Hapus akun user yang tidak memiliki data driver?"
            onConfirm={handleCleanupUsers}
            okText="Ya"
            cancelText="Tidak"
            okButtonProps={{ danger: true }}
          >
            <Button danger loading={loading}>
              Bersihkan User Orphan
            </Button>
          </Popconfirm>
          <Button 
            type="primary" 
            icon={<UserAddOutlined />}
            onClick={() => navigate('/drivers/create')}
          >
            Buat Akun Driver
          </Button>
        </Space>
        </div>
        {syncStatus && (
          <div style={{ padding: 8, backgroundColor: syncStatus.is_synchronized ? '#f6ffed' : '#fff2e8', border: `1px solid ${syncStatus.is_synchronized ? '#b7eb8f' : '#ffbb96'}`, borderRadius: 4 }}>
            <span style={{ color: syncStatus.is_synchronized ? '#52c41a' : '#fa8c16' }}>
              Status DB: {syncStatus.is_synchronized ? 'Tersinkronisasi' : 'Tidak Sinkron'} | 
              Total Users: {syncStatus.total_users} | 
              Total Drivers: {syncStatus.total_drivers} | 
              User Orphan: {syncStatus.orphaned_users_count}
            </span>
          </div>
        )}
      </div>
      
      <Table
        columns={columns}
        dataSource={drivers}
        rowKey="id_driver"
        loading={loading}
      />

      <Modal
        title="Detail Driver"
        open={detailVisible}
        onCancel={() => setDetailVisible(false)}
        footer={null}
        width={1000}
      >
        {selectedDriver && (
          <div>
            <div style={{ marginBottom: 24 }}>
              <h3>Informasi Dasar</h3>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
                <p><strong>Nama:</strong> {selectedDriver.nama}</p>
                <p><strong>Email:</strong> {selectedDriver.email}</p>
                <p><strong>No HP:</strong> {selectedDriver.no_hp}</p>
                <p><strong>Alamat:</strong> {selectedDriver.alamat}</p>
                <p><strong>TTL:</strong> {selectedDriver.ttl}</p>
                <p><strong>Status:</strong> <Tag color={getStatusColor(selectedDriver.status)}>{selectedDriver.status.toUpperCase()}</Tag></p>
                <p><strong>Status Online:</strong> 
                  {onlineDrivers[selectedDriver.id_driver] ? (
                    <Tag color="green">ONLINE di {onlineDrivers[selectedDriver.id_driver].kota}</Tag>
                  ) : (
                    <Tag color="red">OFFLINE</Tag>
                  )}
                </p>
                <p><strong>Kota:</strong> {selectedDriver.kota}</p>
              </div>
            </div>
            
            <div>
              <h3>Dokumen & Foto</h3>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 16, marginBottom: 16 }}>
                {selectedDriver.foto_ktp && (
                  <div style={{ textAlign: 'center' }}>
                    <p><strong>Foto KTP</strong></p>
                    <Image 
                      width={150} 
                      height={100}
                      style={{ objectFit: 'cover', cursor: 'pointer' }}
                      src={`data:image/jpeg;base64,${selectedDriver.foto_ktp}`}
                      onClick={() => showPhotoDetail('ktp', selectedDriver)}
                    />
                  </div>
                )}
                {selectedDriver.foto_sim && (
                  <div style={{ textAlign: 'center' }}>
                    <p><strong>Foto SIM</strong></p>
                    <Image 
                      width={150} 
                      height={100}
                      style={{ objectFit: 'cover', cursor: 'pointer' }}
                      src={`data:image/jpeg;base64,${selectedDriver.foto_sim}`}
                      onClick={() => showPhotoDetail('sim', selectedDriver)}
                    />
                  </div>
                )}
                {selectedDriver.foto_profil && (
                  <div style={{ textAlign: 'center' }}>
                    <p><strong>Foto Profil</strong></p>
                    <Image 
                      width={150} 
                      height={100}
                      style={{ objectFit: 'cover', cursor: 'pointer' }}
                      src={`data:image/jpeg;base64,${selectedDriver.foto_profil}`}
                      onClick={() => showPhotoDetail('profil', selectedDriver)}
                    />
                  </div>
                )}
              </div>
              
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 16 }}>
                {selectedDriver.foto_sertifikat && (
                  <div style={{ textAlign: 'center' }}>
                    <p><strong>Foto Sertifikat</strong></p>
                    <Image 
                      width={150} 
                      height={100}
                      style={{ objectFit: 'cover', cursor: 'pointer' }}
                      src={`data:image/jpeg;base64,${selectedDriver.foto_sertifikat}`}
                      onClick={() => showPhotoDetail('sertifikat', selectedDriver)}
                    />
                  </div>
                )}
                {selectedDriver.foto_bpjs && (
                  <div style={{ textAlign: 'center' }}>
                    <p><strong>Foto BPJS</strong></p>
                    <Image 
                      width={150} 
                      height={100}
                      style={{ objectFit: 'cover', cursor: 'pointer' }}
                      src={`data:image/jpeg;base64,${selectedDriver.foto_bpjs}`}
                      onClick={() => showPhotoDetail('bpjs', selectedDriver)}
                    />
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </Modal>

      <Modal
        title="Update Status Driver"
        open={statusVisible}
        onOk={handleStatusUpdate}
        onCancel={() => setStatusVisible(false)}
      >
        <Select
          value={newStatus}
          onChange={setNewStatus}
          style={{ width: '100%', marginBottom: 16 }}
        >
          <Option value="active">Active</Option>
          <Option value="pending">Pending</Option>
          {selectedDriver?.status !== 'active' && (
            <Option value="training">Training</Option>
          )}
          <Option value="suspended">Suspended</Option>
          <Option value="rejected">Rejected</Option>
        </Select>
        {newStatus === 'rejected' && (
          <TextArea
            placeholder="Alasan penolakan"
            value={rejectionReason}
            onChange={(e) => setRejectionReason(e.target.value)}
          />
        )}
      </Modal>

      <Modal
        title={`Tolak Driver - ${selectedDriver?.nama}`}
        open={rejectVisible}
        onOk={handleReject}
        onCancel={() => {
          setRejectVisible(false);
          setRejectionReason('');
          setRejectionType('');
          setRejectionDocs([]);
        }}
        okText="Tolak"
        cancelText="Batal"
        okButtonProps={{ danger: true }}
      >
        <div style={{ marginBottom: 16 }}>
          <p><strong>Pilih alasan penolakan:</strong></p>
          <Radio.Group 
            value={rejectionType} 
            onChange={(e) => {
              setRejectionType(e.target.value);
              if (e.target.value !== 'dokumen_tidak_jelas') {
                setRejectionDocs([]);
              }
            }}
            style={{ width: '100%' }}
          >
            <Radio value="dokumen_tidak_jelas" style={{ display: 'block', marginBottom: 8 }}>
              Dokumen tidak jelas/tidak sesuai
            </Radio>
            <Radio value="data_tidak_valid" style={{ display: 'block', marginBottom: 8 }}>
              Data tidak valid
            </Radio>
            <Radio value="persyaratan_tidak_lengkap" style={{ display: 'block', marginBottom: 8 }}>
              Persyaratan tidak lengkap
            </Radio>
            <Radio value="lainnya" style={{ display: 'block', marginBottom: 8 }}>
              Lainnya
            </Radio>
          </Radio.Group>
        </div>

        {rejectionType === 'dokumen_tidak_jelas' && (
          <div style={{ marginBottom: 16, padding: 16, backgroundColor: '#f5f5f5', borderRadius: 6 }}>
            <p><strong>Pilih dokumen yang bermasalah:</strong></p>
            <Checkbox.Group 
              value={rejectionDocs}
              onChange={setRejectionDocs}
            >
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                <Checkbox value="ktp">KTP</Checkbox>
                <Checkbox value="sim">SIM</Checkbox>
                <Checkbox value="bpjs">BPJS</Checkbox>
                <Checkbox value="sertifikat">Sertifikat</Checkbox>
                <Checkbox value="profil">Foto Profil</Checkbox>
              </div>
            </Checkbox.Group>
          </div>
        )}

        {(rejectionType === 'lainnya' || rejectionType === 'data_tidak_valid' || rejectionType === 'persyaratan_tidak_lengkap') && (
          <div>
            <p><strong>Keterangan tambahan:</strong></p>
            <TextArea
              placeholder="Masukkan keterangan detail..."
              value={rejectionReason}
              onChange={(e) => setRejectionReason(e.target.value)}
              rows={4}
            />
          </div>
        )}
      </Modal>

      <Modal
        title={selectedPhoto ? getPhotoData(selectedPhoto.type, selectedPhoto.driver).title : ''}
        open={photoDetailVisible}
        onCancel={() => setPhotoDetailVisible(false)}
        footer={null}
        width={600}
      >
        {selectedPhoto && (
          <div>
            <div style={{ textAlign: 'center', marginBottom: 24 }}>
              <Image 
                width={300}
                src={`data:image/jpeg;base64,${getPhotoData(selectedPhoto.type, selectedPhoto.driver).image}`}
              />
            </div>
            <div>
              <h4>Data yang Diinput:</h4>
              {getPhotoData(selectedPhoto.type, selectedPhoto.driver).data.map((item, index) => (
                <div key={index} style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0', borderBottom: '1px solid #f0f0f0' }}>
                  <strong>{item.label}:</strong>
                  <span>{item.value || '-'}</span>
                </div>
              ))}
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default DriverManagement;