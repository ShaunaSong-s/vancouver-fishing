'use client';

import { useState, useEffect, useCallback } from 'react';
import { jsPDF } from 'jspdf';
import * as XLSX from 'xlsx';

interface Booking {
  bookingId: string;
  boatId: string;
  bookingType: string;
  date: string;
  passengers: number;
  name: string;
  phone: string;
  email: string;
  wechat?: string;
  paymentMethod: string;
  totalPrice: number;
  deposit: number;
  status: 'pending' | 'confirmed' | 'cancelled';
  notes?: string;
  createdAt: string;
}

interface Invoice {
  id: string;
  invoiceNumber: string;
  createdAt: string;
  status: 'draft' | 'sent' | 'paid' | 'cancelled';
  customerName: string;
  customerEmail?: string;
  customerPhone?: string;
  description: string;
  amount: number;
  date: string;
  taxRate: number;
  taxAmount: number;
  total: number;
  notes?: string;
}

const STATUS_COLORS = {
  pending: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  confirmed: 'bg-green-100 text-green-800 border-green-200',
  cancelled: 'bg-red-100 text-red-800 border-red-200',
};

const STATUS_LABELS: Record<string, string> = {
  pending: '待确认',
  confirmed: '已确认',
  cancelled: '已取消',
};

export default function AdminPage() {
  const [password, setPassword] = useState('');
  const [authed, setAuthed] = useState(false);
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [filter, setFilter] = useState<'all' | 'pending' | 'confirmed' | 'cancelled'>('all');
  const [activeTab, setActiveTab] = useState<'bookings' | 'invoices' | 'bookkeeping'>('bookings');

  // Invoice form state
  const [invoiceForm, setInvoiceForm] = useState({
    customerName: '', customerEmail: '', customerPhone: '',
    description: '', amount: '', date: '', notes: '',
  });

  // Bookkeeping state
  interface BkEntry {
    id: string; createdAt: string; date: string; type: 'income' | 'expense';
    category: string; amount: number; description: string;
    paymentMethod?: string; reference?: string; receiptUrl?: string; notes?: string;
  }
  const [bkEntries, setBkEntries] = useState<BkEntry[]>([]);
  const [bkForm, setBkForm] = useState({
    date: '', type: 'expense' as 'income' | 'expense', category: '',
    amount: '', description: '', paymentMethod: '', reference: '', notes: '',
  });
  const [bkSummary, setBkSummary] = useState<{ month: string; totalIncome: number; totalExpense: number; net: number; byCategory: { category: string; amount: number }[] } | null>(null);

  const INCOME_CATS = ['Charter Revenue', 'Shared Trip Revenue', 'Tips', 'Merchandise', 'Other Income'];
  const EXPENSE_CATS = ['Fuel', 'Boat Maintenance', 'Dock Fees', 'Insurance', 'Fishing Gear', 'Bait & Tackle', 'License & Permits', 'Marketing', 'Staff Wages', 'Food & Beverages', 'Office & Admin', 'Other Expense'];

  const fetchBkEntries = useCallback(async () => {
    try {
      const res = await fetch('/api/admin/bookkeeping', {
        headers: { Authorization: `Bearer ${password}` },
      });
      if (res.ok) {
        const data = await res.json();
        setBkEntries(data.entries || []);
      }
    } catch { /* ignore */ }
  }, [password]);

  const fetchBkSummary = useCallback(async () => {
    const now = new Date();
    try {
      const res = await fetch(`/api/admin/bookkeeping?year=${now.getFullYear()}&month=${now.getMonth() + 1}`, {
        headers: { Authorization: `Bearer ${password}` },
      });
      if (res.ok) {
        const data = await res.json();
        setBkSummary(data.summary);
      }
    } catch { /* ignore */ }
  }, [password]);

  const [receiptFile, setReceiptFile] = useState<File | null>(null);

  const compressImage = (file: File): Promise<Blob> => {
    return new Promise((resolve) => {
      if (!file.type.startsWith('image/')) {
        resolve(file);
        return;
      }
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        const maxWidth = 800;
        const scale = Math.min(1, maxWidth / img.width);
        canvas.width = img.width * scale;
        canvas.height = img.height * scale;
        const ctx = canvas.getContext('2d')!;
        ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
        canvas.toBlob((blob) => resolve(blob || file), 'image/jpeg', 0.7);
      };
      img.src = URL.createObjectURL(file);
    });
  };

  const createBkEntry = async (e: React.FormEvent) => {
    e.preventDefault();
    let receiptUrl = '';

    // Upload receipt if provided (compressed)
    if (receiptFile) {
      const compressed = await compressImage(receiptFile);
      const formData = new FormData();
      formData.append('file', compressed, receiptFile.name.replace(/\.\w+$/, '.jpg'));
      const uploadRes = await fetch('/api/admin/upload', {
        method: 'POST',
        headers: { Authorization: `Bearer ${password}` },
        body: formData,
      });
      if (uploadRes.ok) {
        const data = await uploadRes.json();
        receiptUrl = data.url;
      }
    }

    await fetch('/api/admin/bookkeeping', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${password}` },
      body: JSON.stringify({ ...bkForm, amount: Number(bkForm.amount), receiptUrl }),
    });
    setBkForm({ date: '', type: 'expense', category: '', amount: '', description: '', paymentMethod: '', reference: '', notes: '' });
    setReceiptFile(null);
    await fetchBkEntries();
    await fetchBkSummary();
  };

  const deleteBkEntry = async (id: string) => {
    if (!confirm('确定删除此记录？')) return;
    await fetch('/api/admin/bookkeeping', {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${password}` },
      body: JSON.stringify({ id }),
    });
    await fetchBkEntries();
    await fetchBkSummary();
  };

  const exportToExcel = () => {
    const data = bkEntries.map(e => ({
      '日期': e.date,
      '类型': e.type === 'income' ? '收入' : '支出',
      '分类': e.category,
      '描述': e.description,
      '金额': e.amount,
      '支付方式': e.paymentMethod || '',
      '备注': e.notes || '',
      '凭证链接': e.receiptUrl || '',
    }));
    const ws = XLSX.utils.json_to_sheet(data);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, '记账明细');

    // Add summary sheet
    if (bkSummary) {
      const summaryData = [
        { '项目': '月份', '金额': bkSummary.month },
        { '项目': '总收入', '金额': bkSummary.totalIncome },
        { '项目': '总支出', '金额': bkSummary.totalExpense },
        { '项目': '净利润', '金额': bkSummary.net },
        ...bkSummary.byCategory.map(c => ({ '项目': c.category, '金额': c.amount })),
      ];
      const ws2 = XLSX.utils.json_to_sheet(summaryData);
      XLSX.utils.book_append_sheet(wb, ws2, '月度汇总');
    }

    XLSX.writeFile(wb, `记账_${new Date().toISOString().slice(0, 10)}.xlsx`);
  };

  const fetchBookings = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const res = await fetch('/api/admin/bookings', {
        headers: { Authorization: `Bearer ${password}` },
      });
      if (!res.ok) {
        if (res.status === 401) {
          setAuthed(false);
          setError('密码错误');
          return;
        }
        throw new Error('Failed to fetch');
      }
      const data = await res.json();
      setBookings(data.bookings);
    } catch {
      setError('加载失败，请重试');
    } finally {
      setLoading(false);
    }
  }, [password]);

  const fetchInvoices = useCallback(async () => {
    try {
      const res = await fetch('/api/admin/invoices', {
        headers: { Authorization: `Bearer ${password}` },
      });
      if (res.ok) {
        const data = await res.json();
        setInvoices(data.invoices);
      }
    } catch { /* ignore */ }
  }, [password]);

  const createInvoice = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const res = await fetch('/api/admin/invoices', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${password}` },
        body: JSON.stringify({ ...invoiceForm, amount: Number(invoiceForm.amount) }),
      });
      if (res.ok) {
        setInvoiceForm({ customerName: '', customerEmail: '', customerPhone: '', description: '', amount: '', date: '', notes: '' });
        await fetchInvoices();
      }
    } catch { setError('创建失败'); }
  };

  const updateInvoiceStatus = async (id: string, status: string) => {
    await fetch('/api/admin/invoices', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${password}` },
      body: JSON.stringify({ id, status }),
    });
    await fetchInvoices();
  };

  const deleteInvoiceItem = async (id: string) => {
    if (!confirm('确定删除此发票？')) return;
    await fetch('/api/admin/invoices', {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${password}` },
      body: JSON.stringify({ id }),
    });
    await fetchInvoices();
  };

  const downloadInvoice = async (inv: Invoice) => {
    const pdf = new jsPDF();

    // Load logo
    try {
      const logoRes = await fetch('/logo-small.png');
      const logoBlob = await logoRes.blob();
      const logoData = await new Promise<string>((resolve) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result as string);
        reader.readAsDataURL(logoBlob);
      });
      pdf.addImage(logoData, 'PNG', 10, 8, 20, 20);
    } catch { /* skip logo if not available */ }

    // Header
    pdf.setFontSize(18);
    pdf.setFont('helvetica', 'bold');
    pdf.text('Top Vancouver Fishing Charter Inc.', 105, 18, { align: 'center' });
    pdf.setFontSize(9);
    pdf.setFont('helvetica', 'normal');
    pdf.text('Georgia Strait | Steveston, BC, Canada', 105, 25, { align: 'center' });
    pdf.setDrawColor(37, 99, 235);
    pdf.setLineWidth(0.5);
    pdf.line(10, 32, 200, 32);

    // Invoice title
    pdf.setFontSize(14);
    pdf.setFont('helvetica', 'bold');
    pdf.text(`INVOICE  ${inv.invoiceNumber}`, 10, 42);

    // Date & status
    pdf.setFontSize(10);
    pdf.setFont('helvetica', 'normal');
    pdf.text(`Date: ${inv.date}`, 10, 50);
    pdf.text(`Status: ${inv.status.toUpperCase()}`, 200, 50, { align: 'right' });

    // Bill To
    pdf.setFontSize(11);
    pdf.setFont('helvetica', 'bold');
    pdf.text('Bill To:', 10, 62);
    pdf.setFontSize(10);
    pdf.setFont('helvetica', 'normal');
    let y = 68;
    pdf.text(inv.customerName, 12, y); y += 5;
    if (inv.customerEmail) { pdf.text(inv.customerEmail, 12, y); y += 5; }
    if (inv.customerPhone) { pdf.text(inv.customerPhone, 12, y); y += 5; }
    y += 10;

    // Table header
    pdf.setFillColor(230, 240, 250);
    pdf.rect(10, y - 5, 130, 8, 'F');
    pdf.rect(140, y - 5, 60, 8, 'F');
    pdf.setFont('helvetica', 'bold');
    pdf.setFontSize(10);
    pdf.text('Description', 12, y);
    pdf.text('Amount', 195, y, { align: 'right' });
    y += 3;
    pdf.line(10, y, 200, y);
    y += 7;

    // Table row
    pdf.setFont('helvetica', 'normal');
    pdf.text(inv.description, 12, y);
    pdf.text(`$${inv.amount.toFixed(2)}`, 195, y, { align: 'right' });
    y += 3;
    pdf.setDrawColor(200, 200, 200);
    pdf.line(10, y, 200, y);
    y += 12;

    // Totals
    pdf.setFont('helvetica', 'normal');
    pdf.text('Subtotal:', 155, y, { align: 'right' });
    pdf.text(`$${inv.amount.toFixed(2)}`, 195, y, { align: 'right' });
    y += 7;
    pdf.text(`GST (${(inv.taxRate * 100).toFixed(0)}%):`, 155, y, { align: 'right' });
    pdf.text(`$${inv.taxAmount.toFixed(2)}`, 195, y, { align: 'right' });
    y += 8;
    pdf.setFont('helvetica', 'bold');
    pdf.setFontSize(12);
    pdf.text('TOTAL:', 155, y, { align: 'right' });
    pdf.text(`$${inv.total.toFixed(2)} CAD`, 195, y, { align: 'right' });

    // Notes
    if (inv.notes) {
      y += 15;
      pdf.setFontSize(10);
      pdf.setFont('helvetica', 'bold');
      pdf.text('Notes:', 10, y);
      pdf.setFont('helvetica', 'normal');
      pdf.setFontSize(9);
      pdf.text(inv.notes, 10, y + 6);
    }

    // Footer
    pdf.setFontSize(8);
    pdf.setFont('helvetica', 'italic');
    pdf.text('Thank you for choosing Top Vancouver Fishing Charter Inc.!', 105, 272, { align: 'center' });
    pdf.text('Payment: E-Transfer to info@topfishingcharter.ca', 105, 277, { align: 'center' });

    pdf.save(`${inv.invoiceNumber}.pdf`);
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setAuthed(true);
    await fetchBookings();
  };

  useEffect(() => {
    if (authed) {
      fetchBookings();
      fetchInvoices();
      fetchBkEntries();
      fetchBkSummary();
      const interval = setInterval(() => { fetchBookings(); fetchInvoices(); fetchBkEntries(); }, 30000);
      return () => clearInterval(interval);
    }
  }, [authed, fetchBookings, fetchInvoices, fetchBkEntries, fetchBkSummary]);

  const updateStatus = async (bookingId: string, status: string) => {
    try {
      const res = await fetch('/api/admin/bookings', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${password}`,
        },
        body: JSON.stringify({ bookingId, status }),
      });
      if (res.ok) {
        await fetchBookings();
      }
    } catch {
      setError('操作失败');
    }
  };

  const handleDelete = async (bookingId: string) => {
    if (!confirm(`确定删除订单 ${bookingId}？此操作不可恢复。`)) return;
    try {
      const res = await fetch('/api/admin/bookings', {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${password}`,
        },
        body: JSON.stringify({ bookingId }),
      });
      if (res.ok) {
        await fetchBookings();
      }
    } catch {
      setError('删除失败');
    }
  };

  const filteredBookings = filter === 'all' ? bookings : bookings.filter(b => b.status === filter);

  const stats = {
    total: bookings.length,
    pending: bookings.filter(b => b.status === 'pending').length,
    confirmed: bookings.filter(b => b.status === 'confirmed').length,
    cancelled: bookings.filter(b => b.status === 'cancelled').length,
    revenue: bookings.filter(b => b.status !== 'cancelled').reduce((sum, b) => sum + b.totalPrice, 0),
  };

  // Login screen
  if (!authed) {
    return (
      <div className="min-h-screen bg-gray-50 text-gray-900 flex items-center justify-center p-4">
        <form onSubmit={handleLogin} className="bg-white rounded-2xl shadow-xl p-8 w-full max-w-sm">
          <div className="text-center mb-6">
            <div className="w-16 h-16 bg-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
            </div>
            <h1 className="text-xl font-bold text-gray-900">管理后台</h1>
            <p className="text-gray-500 text-sm mt-1">Admin Dashboard</p>
          </div>
          {error && <p className="text-red-500 text-sm text-center mb-4">{error}</p>}
          <input
            type="password"
            value={password}
            onChange={e => setPassword(e.target.value)}
            placeholder="请输入管理密码"
            required
            className="w-full border border-gray-200 rounded-xl px-4 py-3 mb-4 focus:outline-none focus:ring-2 focus:ring-blue-400 text-gray-900 bg-white"
          />
          <button
            type="submit"
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-xl transition-colors"
          >
            登录
          </button>
        </form>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center">
              <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
            </div>
            <div>
              <h1 className="text-lg font-bold text-gray-900">海尚海钓 · 管理后台</h1>
              <p className="text-xs text-gray-500">Booking Management</p>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={() => { fetchBookings(); fetchInvoices(); }}
              className="text-gray-500 hover:text-blue-600 p-2 rounded-lg hover:bg-blue-50 transition-colors"
              title="刷新"
            >
              <svg className={`w-5 h-5 ${loading ? 'animate-spin' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
            </button>
            <a href="/" className="text-sm text-gray-500 hover:text-blue-600">← 返回网站</a>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {/* Tab switcher */}
        <div className="flex gap-1 mb-6 bg-gray-100 rounded-xl p-1 w-fit">
          <button
            onClick={() => setActiveTab('bookings')}
            className={`px-5 py-2.5 rounded-lg text-sm font-medium transition-colors ${
              activeTab === 'bookings' ? 'bg-white text-blue-700 shadow-sm' : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            📋 预定管理
          </button>
          <button
            onClick={() => setActiveTab('invoices')}
            className={`px-5 py-2.5 rounded-lg text-sm font-medium transition-colors ${
              activeTab === 'invoices' ? 'bg-white text-blue-700 shadow-sm' : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            🧾 发票管理
          </button>
          <button
            onClick={() => setActiveTab('bookkeeping')}
            className={`px-5 py-2.5 rounded-lg text-sm font-medium transition-colors ${
              activeTab === 'bookkeeping' ? 'bg-white text-blue-700 shadow-sm' : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            📊 记账
          </button>
        </div>

        {activeTab === 'invoices' ? (
          <>
            {/* Create Invoice Form */}
            <div className="bg-white rounded-xl border border-gray-100 p-6 mb-6">
              <h2 className="text-lg font-bold text-gray-900 mb-4">创建发票</h2>
              <form onSubmit={createInvoice} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-xs font-medium text-gray-500 mb-1">客户姓名 *</label>
                    <input type="text" required value={invoiceForm.customerName}
                      onChange={e => setInvoiceForm({...invoiceForm, customerName: e.target.value})}
                      className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-500 mb-1">邮箱</label>
                    <input type="email" value={invoiceForm.customerEmail}
                      onChange={e => setInvoiceForm({...invoiceForm, customerEmail: e.target.value})}
                      className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-500 mb-1">电话</label>
                    <input type="tel" value={invoiceForm.customerPhone}
                      onChange={e => setInvoiceForm({...invoiceForm, customerPhone: e.target.value})}
                      className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
                  </div>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="md:col-span-1">
                    <label className="block text-xs font-medium text-gray-500 mb-1">描述 *</label>
                    <input type="text" required value={invoiceForm.description}
                      onChange={e => setInvoiceForm({...invoiceForm, description: e.target.value})}
                      placeholder="e.g. Full day charter trip"
                      className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-500 mb-1">金额 (CAD) *</label>
                    <input type="number" required step="0.01" min="0" value={invoiceForm.amount}
                      onChange={e => setInvoiceForm({...invoiceForm, amount: e.target.value})}
                      className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-500 mb-1">日期 *</label>
                    <input type="date" required value={invoiceForm.date}
                      onChange={e => setInvoiceForm({...invoiceForm, date: e.target.value})}
                      className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
                  </div>
                </div>
                <div>
                  <label className="block text-xs font-medium text-gray-500 mb-1">备注</label>
                  <input type="text" value={invoiceForm.notes}
                    onChange={e => setInvoiceForm({...invoiceForm, notes: e.target.value})}
                    className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400" />
                </div>
                {invoiceForm.amount && (
                  <p className="text-xs text-gray-500">
                    小计: ${Number(invoiceForm.amount).toFixed(2)} + GST 5%: ${(Number(invoiceForm.amount) * 0.05).toFixed(2)} = 总计: <strong>${(Number(invoiceForm.amount) * 1.05).toFixed(2)}</strong>
                  </p>
                )}
                <button type="submit" className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition-colors">
                  创建发票
                </button>
              </form>
            </div>

            {/* Invoice List */}
            <div className="bg-white rounded-xl border border-gray-100 overflow-hidden">
              <div className="p-4 border-b border-gray-100">
                <h2 className="text-lg font-bold text-gray-900">发票列表 ({invoices.length})</h2>
              </div>
              {invoices.length === 0 ? (
                <div className="p-12 text-center text-gray-400">暂无发票</div>
              ) : (
                <table className="w-full text-sm">
                  <thead className="bg-gray-50 text-xs text-gray-500 uppercase">
                    <tr>
                      <th className="px-4 py-3 text-left">发票号</th>
                      <th className="px-4 py-3 text-left">客户</th>
                      <th className="px-4 py-3 text-left">描述</th>
                      <th className="px-4 py-3 text-left">日期</th>
                      <th className="px-4 py-3 text-right">总额</th>
                      <th className="px-4 py-3 text-center">状态</th>
                      <th className="px-4 py-3 text-center">操作</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-50">
                    {invoices.map(inv => (
                      <tr key={inv.id} className="hover:bg-gray-50">
                        <td className="px-4 py-3 font-mono text-xs">{inv.invoiceNumber}</td>
                        <td className="px-4 py-3 font-medium">{inv.customerName}</td>
                        <td className="px-4 py-3 text-gray-600">{inv.description}</td>
                        <td className="px-4 py-3">{inv.date}</td>
                        <td className="px-4 py-3 text-right font-semibold">${inv.total.toFixed(2)}</td>
                        <td className="px-4 py-3 text-center">
                          <span className={`px-2 py-1 rounded-full text-xs font-medium border ${
                            inv.status === 'paid' ? 'bg-green-100 text-green-800 border-green-200' :
                            inv.status === 'sent' ? 'bg-blue-100 text-blue-800 border-blue-200' :
                            inv.status === 'cancelled' ? 'bg-red-100 text-red-800 border-red-200' :
                            'bg-yellow-100 text-yellow-800 border-yellow-200'
                          }`}>
                            {inv.status === 'paid' ? '已付' : inv.status === 'sent' ? '已发' : inv.status === 'cancelled' ? '取消' : '草稿'}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-center">
                          <div className="flex gap-1 justify-center">
                            {inv.status === 'draft' && (
                              <button onClick={() => updateInvoiceStatus(inv.id, 'sent')}
                                className="px-2 py-1 text-xs bg-blue-50 text-blue-600 rounded hover:bg-blue-100">发送</button>
                            )}
                            {inv.status !== 'paid' && inv.status !== 'cancelled' && (
                              <button onClick={() => updateInvoiceStatus(inv.id, 'paid')}
                                className="px-2 py-1 text-xs bg-green-50 text-green-600 rounded hover:bg-green-100">已付</button>
                            )}
                            {inv.status !== 'cancelled' && (
                              <button onClick={() => updateInvoiceStatus(inv.id, 'cancelled')}
                                className="px-2 py-1 text-xs bg-gray-50 text-gray-500 rounded hover:bg-red-50 hover:text-red-500">取消</button>
                            )}
                            <button onClick={() => downloadInvoice(inv)}
                              className="px-2 py-1 text-xs bg-purple-50 text-purple-600 rounded hover:bg-purple-100">下载</button>
                            <button onClick={() => deleteInvoiceItem(inv.id)}
                              className="px-2 py-1 text-xs bg-gray-50 text-gray-400 rounded hover:bg-red-50 hover:text-red-500">🗑</button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
            <p className="text-xs text-gray-400 mt-4">Payment: E-Transfer to info@topfishingcharter.ca</p>
          </>
        ) : activeTab === 'bookkeeping' ? (
          <>
            {/* Monthly Summary */}
            {bkSummary && (
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <div className="bg-green-50 rounded-xl p-4 border border-green-100">
                  <div className="text-2xl font-bold text-green-700">${bkSummary.totalIncome.toLocaleString()}</div>
                  <div className="text-xs text-green-600 mt-1">本月收入</div>
                </div>
                <div className="bg-red-50 rounded-xl p-4 border border-red-100">
                  <div className="text-2xl font-bold text-red-700">${bkSummary.totalExpense.toLocaleString()}</div>
                  <div className="text-xs text-red-600 mt-1">本月支出</div>
                </div>
                <div className={`rounded-xl p-4 border ${bkSummary.net >= 0 ? 'bg-blue-50 border-blue-100' : 'bg-orange-50 border-orange-100'}`}>
                  <div className={`text-2xl font-bold ${bkSummary.net >= 0 ? 'text-blue-700' : 'text-orange-700'}`}>${bkSummary.net.toLocaleString()}</div>
                  <div className="text-xs text-gray-600 mt-1">净利润</div>
                </div>
                <div className="bg-white rounded-xl p-4 border border-gray-100">
                  <div className="text-2xl font-bold text-gray-900">{bkEntries.length}</div>
                  <div className="text-xs text-gray-500 mt-1">总记录</div>
                </div>
              </div>
            )}

            {/* Add Entry Form */}
            <div className="bg-white rounded-xl border border-gray-100 p-6 mb-6">
              <h2 className="text-lg font-bold text-gray-900 mb-4">添加记录</h2>
              <form onSubmit={createBkEntry} className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <input type="date" required value={bkForm.date} onChange={e => setBkForm({...bkForm, date: e.target.value})}
                    className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 focus:outline-none" />
                  <select value={bkForm.type} onChange={e => setBkForm({...bkForm, type: e.target.value as 'income' | 'expense', category: ''})}
                    className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 focus:outline-none">
                    <option value="expense">📉 支出</option>
                    <option value="income">📈 收入</option>
                  </select>
                  <select required value={bkForm.category} onChange={e => setBkForm({...bkForm, category: e.target.value})}
                    className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 focus:outline-none">
                    <option value="">选择分类...</option>
                    {(bkForm.type === 'income' ? INCOME_CATS : EXPENSE_CATS).map(c => (
                      <option key={c} value={c}>{c}</option>
                    ))}
                  </select>
                  <input type="number" step="0.01" required placeholder="金额" value={bkForm.amount} onChange={e => setBkForm({...bkForm, amount: e.target.value})}
                    className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 focus:outline-none" />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <input type="text" required placeholder="描述" value={bkForm.description} onChange={e => setBkForm({...bkForm, description: e.target.value})}
                    className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 focus:outline-none" />
                  <input type="text" placeholder="支付方式 (可选)" value={bkForm.paymentMethod} onChange={e => setBkForm({...bkForm, paymentMethod: e.target.value})}
                    className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 focus:outline-none" />
                  <input type="text" placeholder="参考号/备注 (可选)" value={bkForm.notes} onChange={e => setBkForm({...bkForm, notes: e.target.value})}
                    className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 focus:outline-none" />
                </div>
                <div className="flex items-center gap-4">
                  <label className="flex items-center gap-2 cursor-pointer px-4 py-2 border border-dashed border-gray-300 rounded-lg hover:border-blue-400 hover:bg-blue-50 transition-colors">
                    <span className="text-sm text-gray-600">📎 {receiptFile ? receiptFile.name : '上传小票/收据'}</span>
                    <input type="file" accept="image/*,.pdf" className="hidden" onChange={e => setReceiptFile(e.target.files?.[0] || null)} />
                  </label>
                  {receiptFile && (
                    <button type="button" onClick={() => setReceiptFile(null)} className="text-xs text-red-500 hover:text-red-700">✕ 移除</button>
                  )}
                </div>
                <button type="submit" className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition-colors">
                  ➕ 添加记录
                </button>
              </form>
            </div>

            {/* Entries Table */}
            <div className="bg-white rounded-xl border border-gray-100 overflow-hidden">
              <div className="flex items-center justify-between p-4 border-b border-gray-100">
                <h3 className="text-lg font-bold text-gray-900">记录列表</h3>
                <button onClick={exportToExcel} className="px-4 py-2 bg-green-600 hover:bg-green-700 text-white text-sm font-medium rounded-lg transition-colors">
                  📥 导出 Excel
                </button>
              </div>
              {bkEntries.length === 0 ? (
                <div className="p-12 text-center text-gray-400">暂无记录</div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead className="bg-gray-50 text-gray-500 text-xs uppercase">
                      <tr>
                        <th className="px-4 py-3 text-left">日期</th>
                        <th className="px-4 py-3 text-left">类型</th>
                        <th className="px-4 py-3 text-left">分类</th>
                        <th className="px-4 py-3 text-left">描述</th>
                        <th className="px-4 py-3 text-right">金额</th>
                        <th className="px-4 py-3 text-left">支付方式</th>
                        <th className="px-4 py-3 text-center">凭证</th>
                        <th className="px-4 py-3 text-center">操作</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-50">
                      {bkEntries.map(entry => (
                        <tr key={entry.id} className="hover:bg-gray-50">
                          <td className="px-4 py-3">{entry.date}</td>
                          <td className="px-4 py-3">
                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                              entry.type === 'income' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                            }`}>
                              {entry.type === 'income' ? '收入' : '支出'}
                            </span>
                          </td>
                          <td className="px-4 py-3 text-gray-600">{entry.category}</td>
                          <td className="px-4 py-3">{entry.description}</td>
                          <td className={`px-4 py-3 text-right font-semibold ${entry.type === 'income' ? 'text-green-700' : 'text-red-700'}`}>
                            {entry.type === 'income' ? '+' : '-'}${entry.amount.toFixed(2)}
                          </td>
                          <td className="px-4 py-3 text-gray-500">{entry.paymentMethod || '-'}</td>
                          <td className="px-4 py-3 text-center">
                            {entry.receiptUrl ? (
                              <a href={entry.receiptUrl} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-800 text-xs">📎 查看</a>
                            ) : <span className="text-gray-300">-</span>}
                          </td>
                          <td className="px-4 py-3 text-center">
                            <button onClick={() => deleteBkEntry(entry.id)}
                              className="px-2 py-1 text-xs bg-gray-50 text-gray-400 rounded hover:bg-red-50 hover:text-red-500">🗑</button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </>
        ) : (
        <>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
          <div className="bg-white rounded-xl p-4 border border-gray-100">
            <div className="text-2xl font-bold text-gray-900">{stats.total}</div>
            <div className="text-xs text-gray-500 mt-1">总预定</div>
          </div>
          <div className="bg-yellow-50 rounded-xl p-4 border border-yellow-100">
            <div className="text-2xl font-bold text-yellow-700">{stats.pending}</div>
            <div className="text-xs text-yellow-600 mt-1">待确认</div>
          </div>
          <div className="bg-green-50 rounded-xl p-4 border border-green-100">
            <div className="text-2xl font-bold text-green-700">{stats.confirmed}</div>
            <div className="text-xs text-green-600 mt-1">已确认</div>
          </div>
          <div className="bg-red-50 rounded-xl p-4 border border-red-100">
            <div className="text-2xl font-bold text-red-700">{stats.cancelled}</div>
            <div className="text-xs text-red-600 mt-1">已取消</div>
          </div>
          <div className="bg-blue-50 rounded-xl p-4 border border-blue-100">
            <div className="text-2xl font-bold text-blue-700">${stats.revenue.toLocaleString()}</div>
            <div className="text-xs text-blue-600 mt-1">预期收入 (CAD)</div>
          </div>
        </div>

        {/* Filter tabs */}
        <div className="flex gap-2 mb-4">
          {(['all', 'pending', 'confirmed', 'cancelled'] as const).map(f => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                filter === f
                  ? 'bg-blue-600 text-white'
                  : 'bg-white text-gray-600 hover:bg-gray-100 border border-gray-200'
              }`}
            >
              {f === 'all' ? `全部 (${stats.total})` :
               f === 'pending' ? `待确认 (${stats.pending})` :
               f === 'confirmed' ? `已确认 (${stats.confirmed})` :
               `已取消 (${stats.cancelled})`}
            </button>
          ))}
        </div>

        {error && <p className="text-red-500 text-sm mb-4">{error}</p>}

        {/* Bookings list */}
        {filteredBookings.length === 0 ? (
          <div className="bg-white rounded-xl p-12 text-center border border-gray-100">
            <svg className="w-12 h-12 text-gray-300 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
            <p className="text-gray-400">暂无预定记录</p>
          </div>
        ) : (
          <div className="space-y-4">
            {filteredBookings.map(booking => (
              <div key={booking.bookingId} className="bg-white rounded-xl border border-gray-100 overflow-hidden hover:shadow-md transition-shadow">
                <div className="p-5">
                  <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3 mb-4">
                    <div className="flex items-center gap-3">
                      <span className={`px-3 py-1 rounded-full text-xs font-medium border ${STATUS_COLORS[booking.status]}`}>
                        {STATUS_LABELS[booking.status]}
                      </span>
                      <span className="text-sm font-mono text-gray-500">{booking.bookingId}</span>
                      <span className="text-xs text-gray-400">
                        {new Date(booking.createdAt).toLocaleString('zh-CN')}
                      </span>
                    </div>
                    <div className="flex gap-2">
                      {booking.status === 'pending' && (
                        <button
                          onClick={() => updateStatus(booking.bookingId, 'confirmed')}
                          className="px-3 py-1.5 bg-green-500 hover:bg-green-600 text-white text-xs font-medium rounded-lg transition-colors"
                        >
                          ✓ 确认
                        </button>
                      )}
                      {booking.status !== 'cancelled' && (
                        <button
                          onClick={() => updateStatus(booking.bookingId, 'cancelled')}
                          className="px-3 py-1.5 bg-gray-100 hover:bg-red-50 text-gray-600 hover:text-red-600 text-xs font-medium rounded-lg transition-colors border border-gray-200"
                        >
                          取消
                        </button>
                      )}
                      {booking.status === 'cancelled' && (
                        <button
                          onClick={() => updateStatus(booking.bookingId, 'pending')}
                          className="px-3 py-1.5 bg-gray-100 hover:bg-yellow-50 text-gray-600 text-xs font-medium rounded-lg transition-colors border border-gray-200"
                        >
                          恢复
                        </button>
                      )}
                      <button
                        onClick={() => handleDelete(booking.bookingId)}
                        className="px-3 py-1.5 bg-gray-100 hover:bg-red-50 text-gray-400 hover:text-red-500 text-xs rounded-lg transition-colors border border-gray-200"
                        title="删除"
                      >
                        🗑
                      </button>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4 text-sm">
                    <div>
                      <div className="text-gray-400 text-xs mb-1">客户</div>
                      <div className="font-semibold text-gray-900">{booking.name}</div>
                    </div>
                    <div>
                      <div className="text-gray-400 text-xs mb-1">电话</div>
                      <a href={`tel:${booking.phone}`} className="text-blue-600 hover:underline">{booking.phone}</a>
                    </div>
                    <div>
                      <div className="text-gray-400 text-xs mb-1">船只</div>
                      <div>{booking.boatId === 'kingfisher' ? 'Kingfisher 3025' : 'Axopar 37'}</div>
                    </div>
                    <div>
                      <div className="text-gray-400 text-xs mb-1">类型 / 人数</div>
                      <div>{booking.bookingType === 'charter' ? '包船' : '拼船'} · {booking.passengers}人</div>
                    </div>
                    <div>
                      <div className="text-gray-400 text-xs mb-1">出海日期</div>
                      <div className="font-semibold text-blue-700">{booking.date}</div>
                    </div>
                    <div>
                      <div className="text-gray-400 text-xs mb-1">金额 / 定金</div>
                      <div className="font-semibold">${booking.totalPrice.toLocaleString()} <span className="text-gray-400 font-normal">/ ${booking.deposit}</span></div>
                    </div>
                  </div>

                  {(booking.email || booking.wechat || booking.notes) && (
                    <div className="mt-3 pt-3 border-t border-gray-50 flex flex-wrap gap-4 text-xs text-gray-500">
                      {booking.email && <span>📧 {booking.email}</span>}
                      {booking.wechat && <span>💬 微信: {booking.wechat}</span>}
                      {booking.paymentMethod && <span>💳 {booking.paymentMethod === 'wechat' ? '微信支付' : '信用卡'}</span>}
                      {booking.notes && <span className="text-gray-600">📝 {booking.notes}</span>}
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
        </>
        )}
      </div>
    </div>
  );
}
