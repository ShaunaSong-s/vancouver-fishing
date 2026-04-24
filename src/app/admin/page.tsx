'use client';

import { useState, useEffect, useCallback } from 'react';

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
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [filter, setFilter] = useState<'all' | 'pending' | 'confirmed' | 'cancelled'>('all');

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

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setAuthed(true);
    await fetchBookings();
  };

  useEffect(() => {
    if (authed) {
      fetchBookings();
      const interval = setInterval(fetchBookings, 30000); // auto-refresh every 30s
      return () => clearInterval(interval);
    }
  }, [authed, fetchBookings]);

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
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
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
            className="w-full border border-gray-200 rounded-xl px-4 py-3 mb-4 focus:outline-none focus:ring-2 focus:ring-blue-400"
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
    <div className="min-h-screen bg-gray-50">
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
              onClick={fetchBookings}
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
        {/* Stats */}
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
      </div>
    </div>
  );
}
