import React, { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, UserX, UserCheck, Eye } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';
import DataTable from '../components/DataTable';
import CustomerModal from '../components/CustomerModal';
import Toast from '../components/Toast';

export default function Customers() {
  const navigate = useNavigate();
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  // Pagination State
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 8;

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCustomer, setEditingCustomer] = useState(null);

  // Toast State
  const [toastMessage, setToastMessage] = useState('');
  const [toastType, setToastType] = useState('success');

  const fetchCustomers = async () => {
    setLoading(true);
    try {
      // Use the new admin user list endpoint
      const response = await api.get('/admin/users');
      if (response.data && response.data.success) {
        setCustomers(response.data.data);
      } else {
        // Fallback to legacy customers endpoint if any issue
        const fallback = await api.get('/customers');
        setCustomers(fallback.data);
      }
    } catch (error) {
      console.error('Failed to load customers:', error);
      showToast('فشل تحميل حسابات المستخدمين من الخادم', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCustomers();
  }, []);

  const showToast = (message, type = 'success') => {
    setToastMessage(message);
    setToastType(type);
  };

  const handleEdit = (e, customer) => {
    e.stopPropagation(); // Prevent navigating to detail page
    setEditingCustomer(customer);
    setIsModalOpen(true);
  };

  const handleAdd = () => {
    setEditingCustomer(null);
    setIsModalOpen(true);
  };

  const handleDelete = async (e, customerId) => {
    e.stopPropagation(); // Prevent navigating to detail page
    if (!window.confirm('هل أنت متأكد من رغبتك في حذف حساب هذا المستخدم نهائياً؟')) return;

    try {
      await api.delete(`/customers/${customerId}`);
      showToast('تم حذف حساب المستخدم بنجاح');
      fetchCustomers();
    } catch (error) {
      console.error('Failed to delete customer:', error);
      showToast('فشل حذف حساب المستخدم من الخادم', 'error');
    }
  };

  const handleSave = () => {
    showToast(editingCustomer ? 'تم تعديل بيانات المستخدم بنجاح' : 'تم إضافة حساب المستخدم بنجاح');
    fetchCustomers();
  };

  // Filtered Customers
  const filteredCustomers = customers.filter((c) => {
    const fullName = c.full_name || '';
    const phone = c.phone || '';
    const name = c.name || '';
    return fullName.toLowerCase().includes(search.toLowerCase()) || 
           name.toLowerCase().includes(search.toLowerCase()) ||
           phone.toLowerCase().includes(search.toLowerCase());
  });

  // Paginated Customers
  const totalPages = Math.ceil(filteredCustomers.length / itemsPerPage);
  const paginatedCustomers = filteredCustomers.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const formatCurrency = (val) => {
    return new Intl.NumberFormat('ar-IQ', { style: 'currency', currency: 'IQD', maximumFractionDigits: 0 }).format(val || 0);
  };

  const headers = ['الاسم', 'رقم الهاتف', 'الطلبات', 'الإنفاق', 'تاريخ التسجيل', 'خيارات التحكم'];

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-black text-gray-800 dark:text-dark-100">حسابات المستخدمين</h1>
        <p className="text-xs text-gray-400 mt-1">عرض، وتعديل، وحذف حسابات العملاء المسجلين في تطبيق الهاتف ومتابعة إحصاءاتهم</p>
      </div>

      {/* Main Table */}
      <DataTable
        title="قائمة حسابات المستخدمين"
        subtitle="اضغط على صف المستخدم لعرض الملف الشخصي الكامل وتفاصيل الطلبات والحجوزات"
        headers={headers}
        data={paginatedCustomers}
        loading={loading}
        searchPlaceholder="ابحث باسم المستخدم أو رقم الهاتف..."
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
            إضافة مستخدم
          </button>
        }
        renderRow={(cust) => (
          <tr 
            key={cust.id} 
            onClick={() => navigate(`/customers/${cust.id}`)}
            className="hover:bg-gray-50/50 dark:hover:bg-dark-950/20 transition-colors cursor-pointer"
          >
            {/* User Avatar & Name */}
            <td className="px-6 py-4">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-950 text-blue-600 dark:text-blue-400 flex items-center justify-center font-bold overflow-hidden">
                  {cust.avatar_url ? (
                    <img src={cust.avatar_url} alt={cust.name || cust.full_name} className="w-full h-full object-cover" />
                  ) : (
                    (cust.name || cust.full_name || 'م').charAt(0)
                  )}
                </div>
                <span className="font-bold text-gray-800 dark:text-dark-200">{cust.name || cust.full_name}</span>
              </div>
            </td>
            {/* Phone */}
            <td className="px-6 py-4 font-mono text-xs text-gray-700 dark:text-dark-300">
              {cust.phone || '—'}
            </td>
            {/* Orders Count */}
            <td className="px-6 py-4 text-xs font-bold text-gray-600 dark:text-dark-400">
              {cust.total_orders ?? 0}
            </td>
            {/* Spent Amount */}
            <td className="px-6 py-4 text-xs font-bold text-emerald-600 dark:text-emerald-400">
              {formatCurrency(cust.total_spent)}
            </td>
            {/* Created At */}
            <td className="px-6 py-4 text-gray-500 dark:text-dark-400 text-xs">
              {cust.created_at ? new Date(cust.created_at).toLocaleDateString('ar-SA') : '—'}
            </td>
            {/* Actions */}
            <td className="px-6 py-4">
              <div className="flex items-center gap-2">
                <button
                  onClick={(e) => { e.stopPropagation(); navigate(`/customers/${cust.id}`); }}
                  className="p-1.5 text-gray-500 hover:bg-gray-50 dark:hover:bg-dark-950/20 rounded-lg transition-colors cursor-pointer"
                  title="عرض الملف الكامل"
                >
                  <Eye size={16} />
                </button>
                <button
                  onClick={(e) => handleEdit(e, cust)}
                  className="p-1.5 text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-950/20 rounded-lg transition-colors cursor-pointer"
                  title="تعديل الحساب"
                >
                  <Edit2 size={16} />
                </button>
                <button
                  onClick={(e) => handleDelete(e, cust.id)}
                  className="p-1.5 text-red-600 hover:bg-red-50 dark:hover:bg-red-950/20 rounded-lg transition-colors cursor-pointer"
                  title="حذف الحساب"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            </td>
          </tr>
        )}
      />

      {/* Customer Edit Modal */}
      <CustomerModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        customer={editingCustomer}
        onSave={handleSave}
      />

      {/* Toast Popup */}
      <Toast 
        message={toastMessage} 
        type={toastType} 
        onClose={() => setToastMessage('')} 
      />
    </div>
  );
}
