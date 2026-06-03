import React, { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, ShieldCheck, ShieldAlert } from 'lucide-react';
import api from '../services/api';
import { useAuth } from '../context/AuthContext';
import DataTable from '../components/DataTable';
import UserModal from '../components/UserModal';
import Toast from '../components/Toast';

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const { user: currentUser } = useAuth();

  // Pagination State
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 8;

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingUser, setEditingUser] = useState(null);

  // Toast State
  const [toastMessage, setToastMessage] = useState('');
  const [toastType, setToastType] = useState('success');

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const response = await api.get('/users');
      setUsers(response.data);
    } catch (error) {
      console.error('Failed to load system users:', error);
      showToast('فشل تحميل المشرفين من الخادم', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const showToast = (message, type = 'success') => {
    setToastMessage(message);
    setToastType(type);
  };

  const handleEdit = (user) => {
    setEditingUser(user);
    setIsModalOpen(true);
  };

  const handleAdd = () => {
    setEditingUser(null);
    setIsModalOpen(true);
  };

  const handleDelete = async (userId) => {
    if (userId === currentUser.id) {
      showToast('لا يمكنك حذف حسابك الحالي', 'error');
      return;
    }
    if (!window.confirm('هل أنت متأكد من رغبتك في حذف هذا الحساب الإداري نهائياً؟')) return;

    try {
      await api.delete(`/users/${userId}`);
      showToast('تم حذف المشرف بنجاح');
      fetchUsers();
    } catch (error) {
      console.error('Failed to delete user:', error);
      showToast('فشل حذف المشرف من الخادم', 'error');
    }
  };

  const handleSave = () => {
    showToast(editingUser ? 'تم تعديل بيانات المشرف بنجاح' : 'تم إضافة المشرف بنجاح');
    fetchUsers();
  };

  // Filtered Users
  const filteredUsers = users.filter((u) => {
    return u.full_name.toLowerCase().includes(search.toLowerCase()) || 
           u.email.toLowerCase().includes(search.toLowerCase());
  });

  // Paginated Users
  const totalPages = Math.ceil(filteredUsers.length / itemsPerPage);
  const paginatedUsers = filteredUsers.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const headers = ['الاسم', 'البريد الإلكتروني', 'الصلاحية', 'الحالة', 'تاريخ الإنشاء', 'خيارات التحكم'];

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-black text-gray-800 dark:text-dark-100">إدارة حسابات المشرفين</h1>
        <p className="text-xs text-gray-400 mt-1">إضافة، تعديل وحذف حسابات المشرفين وتعديل صلاحياتهم الأمنية</p>
      </div>

      {/* Main Table */}
      <DataTable
        title="قائمة المشرفين"
        subtitle="جميع الحسابات الإدارية النشطة في لوحة التحكم"
        headers={headers}
        data={paginatedUsers}
        loading={loading}
        searchPlaceholder="ابحث باسم المشرف أو بريده الإلكتروني..."
        searchValue={search}
        onSearchChange={(val) => { setSearch(val); setCurrentPage(1); }}
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={setCurrentPage}
        actionButton={
          <button
            onClick={handleAdd}
            className="px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow-md transition-colors cursor-pointer"
          >
            <Plus size={16} />
            إضافة مشرف
          </button>
        }
        renderRow={(user) => (
          <tr key={user.id} className="hover:bg-gray-50/50 dark:hover:bg-dark-950/20 transition-colors">
            {/* Name */}
            <td className="px-6 py-4">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-primary-100 dark:bg-primary-950 text-primary-600 dark:text-primary-400 flex items-center justify-center font-bold overflow-hidden">
                  {user.avatar_url ? (
                    <img src={user.avatar_url} alt={user.full_name} className="w-full h-full object-cover" />
                  ) : (
                    user.full_name.charAt(0)
                  )}
                </div>
                <span className="font-bold text-gray-800 dark:text-dark-200">{user.full_name}</span>
                {user.id === currentUser.id && (
                  <span className="text-[9px] font-bold bg-gray-100 dark:bg-dark-800 px-2 py-0.5 rounded-full text-gray-500">
                    أنت
                  </span>
                )}
              </div>
            </td>
            {/* Email */}
            <td className="px-6 py-4 text-gray-600 dark:text-dark-400">
              {user.email}
            </td>
            {/* Role */}
            <td className="px-6 py-4">
              <span className={`inline-flex items-center gap-1.5 text-xs font-bold ${
                user.role === 'superadmin' ? 'text-purple-600 dark:text-purple-400' : 'text-primary-600 dark:text-primary-400'
              }`}>
                {user.role === 'superadmin' ? (
                  <>
                    <ShieldCheck size={14} />
                    مدير عام
                  </>
                ) : (
                  <>
                    <ShieldAlert size={14} />
                    مشرف
                  </>
                )}
              </span>
            </td>
            {/* Status */}
            <td className="px-6 py-4">
              <span className={`inline-block w-2.5 h-2.5 rounded-full mr-2 ${
                user.is_active ? 'bg-emerald-500' : 'bg-red-500'
              }`} title={user.is_active ? 'نشط' : 'معطل'}></span>
              <span className="text-xs font-medium text-gray-600 dark:text-dark-300">
                {user.is_active ? 'نشط' : 'معطل'}
              </span>
            </td>
            {/* Created At */}
            <td className="px-6 py-4 text-gray-500 dark:text-dark-400 text-xs">
              {new Date(user.created_at).toLocaleDateString('ar-SA')}
            </td>
            {/* Actions */}
            <td className="px-6 py-4">
              <div className="flex items-center gap-2">
                <button
                  onClick={() => handleEdit(user)}
                  className="p-1.5 text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-950/20 rounded-lg transition-colors cursor-pointer"
                  title="تعديل الحساب"
                >
                  <Edit2 size={16} />
                </button>
                <button
                  onClick={() => handleDelete(user.id)}
                  disabled={user.id === currentUser.id}
                  className="p-1.5 text-red-600 hover:bg-red-50 dark:hover:bg-red-950/20 rounded-lg transition-colors disabled:opacity-30 disabled:cursor-not-allowed cursor-pointer"
                  title="حذف الحساب"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            </td>
          </tr>
        )}
      />

      {/* User Edit Modal */}
      <UserModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        user={editingUser}
        onSave={handleSave}
      />

      {/* Toast popup */}
      <Toast 
        message={toastMessage} 
        type={toastType} 
        onClose={() => setToastMessage('')} 
      />
    </div>
  );
}
