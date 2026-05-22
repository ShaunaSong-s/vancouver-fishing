'use client';

import { useState } from 'react';
import { useLanguage } from '@/i18n/LanguageContext';
import { useMember } from '@/lib/MemberContext';

export default function MemberBadge() {
  const { lang } = useLanguage();
  const { member, login, register, logout } = useMember();
  const [showModal, setShowModal] = useState(false);
  const [mode, setMode] = useState<'login' | 'register'>('login');
  const [phone, setPhone] = useState('');
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [wechat, setWechat] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    if (!phone) return;
    setLoading(true);
    setError('');
    const result = await login(phone);
    if (!result.success) {
      if (result.message === 'not_found') {
        setMode('register');
        setError(lang === 'zh' ? '未找到该手机号，请注册' : 'Phone not found, please register');
      } else {
        setError(result.message || 'Error');
      }
    } else {
      setShowModal(false);
      resetForm();
    }
    setLoading(false);
  };

  const handleRegister = async () => {
    if (!name || !phone) return;
    setLoading(true);
    setError('');
    const result = await register({ name, phone, email, wechat });
    if (result.success) {
      setShowModal(false);
      resetForm();
    } else {
      setError(result.message || 'Error');
    }
    setLoading(false);
  };

  const resetForm = () => {
    setPhone('');
    setName('');
    setEmail('');
    setWechat('');
    setError('');
    setMode('login');
  };

  const memberTypeLabel: Record<string, string> = {
    new: lang === 'zh' ? '普通会员' : 'Member',
    returning: lang === 'zh' ? '老客户' : 'Returning',
    prepaid: lang === 'zh' ? '充值卡' : 'Prepaid',
    annual: lang === 'zh' ? '年卡会员' : 'Annual',
  };

  // Logged in — show badge
  if (member) {
    return (
      <div className="relative group">
        <button className="flex items-center gap-2 bg-gold-400/10 border border-gold-400/20 text-gold-400 px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-gold-400/20 transition-colors">
          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
          </svg>
          {member.name}
        </button>
        {/* Dropdown */}
        <div className="absolute right-0 top-full mt-1 w-52 bg-sea-800 rounded-xl shadow-xl border border-gold-400/15 p-3 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all z-50">
          <div className="text-xs text-white/50 mb-1">{lang === 'zh' ? '会员编号' : 'Member #'}</div>
          <div className="font-bold text-white text-sm mb-2">{member.memberNo}</div>
          <div className="inline-block text-[10px] font-semibold bg-gold-400/15 text-gold-400 px-2 py-0.5 rounded-md mb-2">
            {memberTypeLabel[member.memberType] || member.memberType}
          </div>
          {member.benefits && (
            <div className="text-xs text-white/60 mb-3 bg-white/5 p-2 rounded-lg">{member.benefits}</div>
          )}
          <button
            onClick={logout}
            className="w-full text-xs text-white/40 hover:text-red-400 font-medium py-1.5 border-t border-white/10 mt-1 transition-colors"
          >
            {lang === 'zh' ? '退出登录' : 'Logout'}
          </button>
        </div>
      </div>
    );
  }

  // Not logged in — show login button
  return (
    <>
      <button
        onClick={() => setShowModal(true)}
        className="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg border border-gold-400/20 text-gold-400/80 hover:border-gold-400/40 hover:text-gold-400 hover:bg-gold-400/5 transition-all"
      >
        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
        </svg>
        {lang === 'zh' ? '登录/注册' : 'Login'}
      </button>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" onClick={() => { setShowModal(false); resetForm(); }} />
          <div className="relative bg-sea-800 border border-gold-400/15 rounded-2xl shadow-2xl w-full max-w-sm p-6 animate-fade-in-up">
            {/* Close */}
            <button
              onClick={() => { setShowModal(false); resetForm(); }}
              className="absolute top-3 right-3 text-white/40 hover:text-white transition-colors"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>

            <h3 className="text-lg font-bold text-white mb-1">
              {mode === 'login'
                ? (lang === 'zh' ? '会员登录' : 'Member Login')
                : (lang === 'zh' ? '会员注册' : 'Register')}
            </h3>
            <p className="text-xs text-white/50 mb-5">
              {mode === 'login'
                ? (lang === 'zh' ? '输入手机号快速登录' : 'Enter your phone to login')
                : (lang === 'zh' ? '注册成为会员享受专属优惠' : 'Register for member benefits')}
            </p>

            {error && (
              <div className="bg-red-500/10 text-red-400 text-xs font-medium p-2.5 rounded-lg mb-4 border border-red-500/20">
                {error}
              </div>
            )}

            <div className="space-y-3">
              {mode === 'register' && (
                <input
                  type="text"
                  placeholder={lang === 'zh' ? '姓名' : 'Name'}
                  value={name}
                  onChange={e => setName(e.target.value)}
                  className="w-full border border-gold-400/15 rounded-xl px-4 py-3 text-sm text-white bg-white/5 focus:outline-none focus:ring-2 focus:ring-gold-400/50 focus:border-transparent placeholder:text-white/30"
                />
              )}
              <input
                type="tel"
                placeholder={lang === 'zh' ? '手机号码' : 'Phone number'}
                value={phone}
                onChange={e => setPhone(e.target.value)}
                className="w-full border border-gold-400/15 rounded-xl px-4 py-3 text-sm text-white bg-white/5 focus:outline-none focus:ring-2 focus:ring-gold-400/50 focus:border-transparent placeholder:text-white/30"
              />
              {mode === 'register' && (
                <>
                  <input
                    type="email"
                    placeholder={lang === 'zh' ? '邮箱（选填）' : 'Email (optional)'}
                    value={email}
                    onChange={e => setEmail(e.target.value)}
                    className="w-full border border-gold-400/15 rounded-xl px-4 py-3 text-sm text-white bg-white/5 focus:outline-none focus:ring-2 focus:ring-gold-400/50 focus:border-transparent placeholder:text-white/30"
                  />
                  <input
                    type="text"
                    placeholder={lang === 'zh' ? '微信号（选填）' : 'WeChat ID (optional)'}
                    value={wechat}
                    onChange={e => setWechat(e.target.value)}
                    className="w-full border border-gold-400/15 rounded-xl px-4 py-3 text-sm text-white bg-white/5 focus:outline-none focus:ring-2 focus:ring-gold-400/50 focus:border-transparent placeholder:text-white/30"
                  />
                </>
              )}
            </div>

            <button
              onClick={mode === 'login' ? handleLogin : handleRegister}
              disabled={loading || !phone || (mode === 'register' && !name)}
              className="w-full mt-5 btn-gold py-3 rounded-xl transition-all disabled:opacity-40 disabled:cursor-not-allowed text-sm"
            >
              {loading
                ? (lang === 'zh' ? '处理中...' : 'Loading...')
                : mode === 'login'
                  ? (lang === 'zh' ? '登录' : 'Login')
                  : (lang === 'zh' ? '注册' : 'Register')}
            </button>

            <button
              onClick={() => { setMode(mode === 'login' ? 'register' : 'login'); setError(''); }}
              className="w-full mt-3 text-xs text-gold-400/70 hover:text-gold-400 font-medium"
            >
              {mode === 'login'
                ? (lang === 'zh' ? '没有账号？立即注册' : "Don't have an account? Register")
                : (lang === 'zh' ? '已有账号？去登录' : 'Already have an account? Login')}
            </button>
          </div>
        </div>
      )}
    </>
  );
}
