'use client';

import React, { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';
import zh from './zh.json';
import en from './en.json';

type Lang = 'zh' | 'en';
type Translations = typeof zh;

interface LanguageContextType {
  lang: Lang;
  setLang: (lang: Lang) => void;
  t: Translations;
}

const translations: Record<Lang, Translations> = { zh, en };

const LanguageContext = createContext<LanguageContextType>({
  lang: 'zh',
  setLang: () => {},
  t: zh,
});

function detectLanguage(): Lang {
  if (typeof window === 'undefined') return 'zh';
  const stored = localStorage.getItem('lang');
  if (stored === 'zh' || stored === 'en') return stored;
  const browserLang = navigator.language || '';
  if (browserLang.startsWith('zh')) return 'zh';
  return 'en';
}

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>('zh');
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setLangState(detectLanguage());
    setMounted(true);
  }, []);

  const setLang = useCallback((newLang: Lang) => {
    setLangState(newLang);
    localStorage.setItem('lang', newLang);
    document.documentElement.lang = newLang;
  }, []);

  useEffect(() => {
    if (mounted) {
      document.documentElement.lang = lang;
    }
  }, [lang, mounted]);

  return (
    <LanguageContext.Provider value={{ lang, setLang, t: translations[lang] }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  return useContext(LanguageContext);
}
