import React, { useState, useEffect } from 'react';
import { Table, Button, Modal, Form, Input, Select, message, Space, Card, Tabs, Switch, InputNumber } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, FileTextOutlined, QuestionCircleOutlined } from '@ant-design/icons';
import { trainingAPI } from '../services/api';

const { Option } = Select;
const { TextArea } = Input;
const { TabPane } = Tabs;

const TrainingManagement = () => {
  const [modules, setModules] = useState([]);
  const [contents, setContents] = useState([]);
  const [quizzes, setQuizzes] = useState([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [contentModalVisible, setContentModalVisible] = useState(false);
  const [quizModalVisible, setQuizModalVisible] = useState(false);
  const [editingModule, setEditingModule] = useState(null);
  const [editingContent, setEditingContent] = useState(null);
  const [editingQuiz, setEditingQuiz] = useState(null);
  const [selectedModuleId, setSelectedModuleId] = useState(null);
  const [form] = Form.useForm();
  const [contentForm] = Form.useForm();
  const [quizForm] = Form.useForm();

  useEffect(() => {
    fetchModules();
  }, []);

  const fetchModules = async () => {
    setLoading(true);
    try {
      const response = await trainingAPI.getModules();
      setModules(response.data);
    } catch (error) {
      message.error('Gagal memuat data training');
    } finally {
      setLoading(false);
    }
  };

  const fetchContents = async (moduleId) => {
    try {
      const response = await trainingAPI.getContents(moduleId);
      setContents(response.data);
    } catch (error) {
      message.error('Gagal memuat konten');
    }
  };

  const fetchQuizzes = async (moduleId) => {
    try {
      const response = await trainingAPI.getQuizzes(moduleId);
      setQuizzes(response.data);
    } catch (error) {
      message.error('Gagal memuat quiz');
    }
  };

  const handleSubmit = async (values) => {
    try {
      if (editingModule) {
        await trainingAPI.updateModule(editingModule.id, values);
        message.success('Module berhasil diupdate');
      } else {
        await trainingAPI.createModule(values);
        message.success('Module berhasil dibuat');
      }
      setModalVisible(false);
      form.resetFields();
      setEditingModule(null);
      fetchModules();
    } catch (error) {
      message.error('Gagal menyimpan module');
    }
  };

  const handleContentSubmit = async (values) => {
    try {
      const data = { ...values, module: selectedModuleId };
      if (editingContent) {
        await trainingAPI.updateContent(editingContent.id, data);
        message.success('Konten berhasil diupdate');
      } else {
        await trainingAPI.createContent(data);
        message.success('Konten berhasil dibuat');
      }
      setContentModalVisible(false);
      contentForm.resetFields();
      setEditingContent(null);
      fetchContents(selectedModuleId);
    } catch (error) {
      message.error('Gagal menyimpan konten');
    }
  };

  const handleQuizSubmit = async (values) => {
    try {
      const data = { ...values, module: selectedModuleId };
      if (editingQuiz) {
        await trainingAPI.updateQuiz(editingQuiz.id, data);
        message.success('Quiz berhasil diupdate');
      } else {
        await trainingAPI.createQuiz(data);
        message.success('Quiz berhasil dibuat');
      }
      setQuizModalVisible(false);
      quizForm.resetFields();
      setEditingQuiz(null);
      fetchQuizzes(selectedModuleId);
    } catch (error) {
      message.error('Gagal menyimpan quiz');
    }
  };

  const handleDelete = async (id) => {
    try {
      await trainingAPI.deleteModule(id);
      message.success('Module berhasil dihapus');
      fetchModules();
    } catch (error) {
      message.error('Gagal menghapus module');
    }
  };

  const columns = [
    {
      title: 'Judul',
      dataIndex: 'title',
      key: 'title',
    },
    {
      title: 'Level',
      dataIndex: 'level',
      key: 'level',
      render: (level) => level.charAt(0).toUpperCase() + level.slice(1),
    },
    {
      title: 'Instruktur',
      dataIndex: 'instructor',
      key: 'instructor',
    },
    {
      title: 'Status',
      dataIndex: 'is_active',
      key: 'is_active',
      render: (active) => active ? 'Aktif' : 'Tidak Aktif',
    },
    {
      title: 'Aksi',
      key: 'action',
      render: (_, record) => (
        <Space>
          <Button 
            icon={<FileTextOutlined />}
            onClick={() => {
              setSelectedModuleId(record.id);
              fetchContents(record.id);
              fetchQuizzes(record.id);
            }}
            title="Kelola Konten"
          />
          <Button 
            icon={<EditOutlined />}
            onClick={() => {
              setEditingModule(record);
              form.setFieldsValue(record);
              setModalVisible(true);
            }}
          />
          <Button 
            icon={<DeleteOutlined />}
            danger
            onClick={() => handleDelete(record.id)}
          />
        </Space>
      ),
    },
  ];

  const contentColumns = [
    { title: 'Judul', dataIndex: 'title', key: 'title' },
    { title: 'Tipe', dataIndex: 'content_type', key: 'content_type' },
    { title: 'Points', dataIndex: 'points', key: 'points' },
    {
      title: 'Aksi',
      key: 'action',
      render: (_, record) => (
        <Space>
          <Button 
            icon={<EditOutlined />}
            onClick={() => {
              setEditingContent(record);
              contentForm.setFieldsValue(record);
              setContentModalVisible(true);
            }}
          />
          <Button 
            icon={<DeleteOutlined />}
            danger
            onClick={async () => {
              try {
                await trainingAPI.deleteContent(record.id);
                message.success('Konten berhasil dihapus');
                fetchContents(selectedModuleId);
              } catch (error) {
                message.error('Gagal menghapus konten');
              }
            }}
          />
        </Space>
      ),
    },
  ];

  const quizColumns = [
    { title: 'Pertanyaan', dataIndex: 'question', key: 'question' },
    { title: 'Jawaban Benar', dataIndex: 'correct_answer', key: 'correct_answer' },
    { title: 'Points', dataIndex: 'points', key: 'points' },
    {
      title: 'Aksi',
      key: 'action',
      render: (_, record) => (
        <Space>
          <Button 
            icon={<EditOutlined />}
            onClick={() => {
              setEditingQuiz(record);
              quizForm.setFieldsValue(record);
              setQuizModalVisible(true);
            }}
          />
          <Button 
            icon={<DeleteOutlined />}
            danger
            onClick={async () => {
              try {
                await trainingAPI.deleteQuiz(record.id);
                message.success('Quiz berhasil dihapus');
                fetchQuizzes(selectedModuleId);
              } catch (error) {
                message.error('Gagal menghapus quiz');
              }
            }}
          />
        </Space>
      ),
    },
  ];

  return (
    <div>
      <Card title="Training Management">
        <Button 
          type="primary" 
          icon={<PlusOutlined />}
          onClick={() => {
            setEditingModule(null);
            form.resetFields();
            setModalVisible(true);
          }}
          style={{ marginBottom: 16 }}
        >
          Tambah Module
        </Button>

        <Table
          columns={columns}
          dataSource={modules}
          rowKey="id"
          loading={loading}
        />
      </Card>

      {selectedModuleId && (
        <Card title={`Konten Module: ${modules.find(m => m.id === selectedModuleId)?.title}`} style={{ marginTop: 16 }}>
          <Tabs defaultActiveKey="1">
            <TabPane tab="Konten" key="1">
              <Button 
                type="primary" 
                icon={<PlusOutlined />}
                onClick={() => {
                  setEditingContent(null);
                  contentForm.resetFields();
                  setContentModalVisible(true);
                }}
                style={{ marginBottom: 16 }}
              >
                Tambah Konten
              </Button>
              <Table
                columns={contentColumns}
                dataSource={contents}
                rowKey="id"
                size="small"
              />
            </TabPane>
            <TabPane tab="Quiz" key="2">
              <Button 
                type="primary" 
                icon={<PlusOutlined />}
                onClick={() => {
                  setEditingQuiz(null);
                  quizForm.resetFields();
                  setQuizModalVisible(true);
                }}
                style={{ marginBottom: 16 }}
              >
                Tambah Quiz
              </Button>
              <Table
                columns={quizColumns}
                dataSource={quizzes}
                rowKey="id"
                size="small"
              />
            </TabPane>
          </Tabs>
        </Card>
      )}

      <Modal
        title={editingModule ? 'Edit Module' : 'Tambah Module'}
        open={modalVisible}
        onCancel={() => {
          setModalVisible(false);
          setEditingModule(null);
          form.resetFields();
        }}
        footer={null}
      >
        <Form form={form} onFinish={handleSubmit} layout="vertical">
          <Form.Item name="title" label="Judul" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="description" label="Deskripsi" rules={[{ required: true }]}>
            <TextArea rows={4} />
          </Form.Item>
          <Form.Item name="level" label="Level" rules={[{ required: true }]}>
            <Select>
              <Option value="pemula">Pemula</Option>
              <Option value="lanjutan">Lanjutan</Option>
              <Option value="expert">Expert</Option>
            </Select>
          </Form.Item>
          <Form.Item name="instructor" label="Instruktur" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="order" label="Urutan" rules={[{ required: true }]}>
            <InputNumber min={1} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="is_active" label="Status" valuePropName="checked" initialValue={true}>
            <Switch checkedChildren="Aktif" unCheckedChildren="Tidak Aktif" />
          </Form.Item>
          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit">
                {editingModule ? 'Update' : 'Simpan'}
              </Button>
              <Button onClick={() => setModalVisible(false)}>
                Batal
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>

      {/* Content Modal */}
      <Modal
        title={editingContent ? 'Edit Konten' : 'Tambah Konten'}
        open={contentModalVisible}
        onCancel={() => {
          setContentModalVisible(false);
          setEditingContent(null);
          contentForm.resetFields();
        }}
        footer={null}
        width={600}
      >
        <Form form={contentForm} onFinish={handleContentSubmit} layout="vertical">
          <Form.Item name="title" label="Judul" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="content_type" label="Tipe Konten" rules={[{ required: true }]}>
            <Select>
              <Option value="narration">Narasi</Option>
              <Option value="image">Gambar</Option>
              <Option value="video">Video</Option>
              <Option value="infographic">Infografis</Option>
            </Select>
          </Form.Item>
          <Form.Item name="text_content" label="Konten Teks">
            <TextArea rows={6} />
          </Form.Item>
          <Form.Item name="youtube_url" label="YouTube URL">
            <Input placeholder="https://youtube.com/watch?v=..." />
          </Form.Item>
          <Form.Item name="points" label="Points" rules={[{ required: true }]}>
            <Input type="number" defaultValue={10} />
          </Form.Item>
          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit">
                {editingContent ? 'Update' : 'Simpan'}
              </Button>
              <Button onClick={() => setContentModalVisible(false)}>
                Batal
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>

      {/* Quiz Modal */}
      <Modal
        title={editingQuiz ? 'Edit Quiz' : 'Tambah Quiz'}
        open={quizModalVisible}
        onCancel={() => {
          setQuizModalVisible(false);
          setEditingQuiz(null);
          quizForm.resetFields();
        }}
        footer={null}
        width={700}
      >
        <Form form={quizForm} onFinish={handleQuizSubmit} layout="vertical">
          <Form.Item name="question" label="Pertanyaan" rules={[{ required: true }]}>
            <TextArea rows={3} />
          </Form.Item>
          <Form.Item name="option_a" label="Pilihan A" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="option_b" label="Pilihan B" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="option_c" label="Pilihan C" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="option_d" label="Pilihan D" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="correct_answer" label="Jawaban Benar" rules={[{ required: true }]}>
            <Select>
              <Option value="A">A</Option>
              <Option value="B">B</Option>
              <Option value="C">C</Option>
              <Option value="D">D</Option>
            </Select>
          </Form.Item>
          <Form.Item name="explanation" label="Penjelasan">
            <TextArea rows={3} />
          </Form.Item>
          <Form.Item name="points" label="Points" rules={[{ required: true }]}>
            <Input type="number" defaultValue={20} />
          </Form.Item>
          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit">
                {editingQuiz ? 'Update' : 'Simpan'}
              </Button>
              <Button onClick={() => setQuizModalVisible(false)}>
                Batal
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default TrainingManagement;