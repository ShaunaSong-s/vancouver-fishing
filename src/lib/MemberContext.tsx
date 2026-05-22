'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface MemberInfo {
  memberNo: string;
  memberType: 'new' | 'prepaid' | 'annual' | 'returning';
  name: string;
  phone: string;
  benefits?: string;
}

interface MemberContextType {
  member: MemberInfo | null;
  loading: boolean;
  login: (phone: string) => Promise<{ success: boolean; message?: string }>;
  register: (data: { name: string; phone: string; email?: string; wechat?: string }) => Promise<{ success: boolean; message?: string }>;
  logout: () => void;
}

const MemberContext = createContext<MemberContextType>({
  member: null,
  loading: true,
  login: async () => ({ success: false }),
  register: async () => ({ success: false }),
  logout: () => {},
});

export function MemberProvider({ children }: { children: ReactNode }) {
  const [member, setMember] = useState<MemberInfo | null>(null);
  const [loading, setLoading] = useState(true);

  // Restore from localStorage on mount
  useEffect(() => {
    try {
      const saved = localStorage.getItem('tf_member');
      if (saved) {
        setMember(JSON.parse(saved));
      }
    } catch {}
    setLoading(false);
  }, []);

  const login = async (phone: string) => {
    try {
      const res = await fetch('/api/member/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone }),
      });
      const data = await res.json();

      if (data.success) {
        const info: MemberInfo = {
          memberNo: data.memberNo,
          memberType: data.memberType,
          name: data.name,
          phone: data.phone,
          benefits: data.benefits,
        };
        setMember(info);
        localStorage.setItem('tf_member', JSON.stringify(info));
        return { success: true };
      }
      return { success: false, message: data.message };
    } catch {
      return { success: false, message: 'Network error' };
    }
  };

  const register = async (data: { name: string; phone: string; email?: string; wechat?: string }) => {
    try {
      const res = await fetch('/api/member/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      const result = await res.json();

      if (result.success) {
        const info: MemberInfo = {
          memberNo: result.memberNo,
          memberType: result.memberType,
          name: result.name || data.name,
          phone: data.phone,
        };
        setMember(info);
        localStorage.setItem('tf_member', JSON.stringify(info));
        return { success: true };
      }
      return { success: false, message: result.message };
    } catch {
      return { success: false, message: 'Network error' };
    }
  };

  const logout = () => {
    setMember(null);
    localStorage.removeItem('tf_member');
  };

  return (
    <MemberContext.Provider value={{ member, loading, login, register, logout }}>
      {children}
    </MemberContext.Provider>
  );
}

export function useMember() {
  return useContext(MemberContext);
}
