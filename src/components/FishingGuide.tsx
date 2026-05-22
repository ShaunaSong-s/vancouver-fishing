'use client';

import { useLanguage } from '@/i18n/LanguageContext';
import { useState } from 'react';
import AnimateOnScroll from './AnimateOnScroll';

type Tab = 'schedule' | 'tips' | 'license' | 'seasons';

const FISH_SEASONS = [
  { zh: '斑点虾', en: 'Spot Prawns', months: [5, 6, 7], icon: '🦐' },
  { zh: '珍宝蟹', en: 'Dungeness Crab', months: [1, 2, 3, 4, 5, 10, 11, 12], icon: '🦀' },
  { zh: '三文鱼', en: 'Salmon', months: [6, 7, 8, 9, 10], icon: '🐟' },
  { zh: '大比目鱼', en: 'Halibut', months: [4, 5, 6, 7, 8], icon: '🐠' },
  { zh: '岩鱼', en: 'Rockfish', months: [5, 6, 7, 8, 9], icon: '🐡' },
  { zh: '鳕鱼', en: 'Lingcod', months: [5, 6, 7, 8, 9], icon: '🎣' },
];

const MONTH_LABELS = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

export default function FishingGuide() {
  const { lang } = useLanguage();
  const [tab, setTab] = useState<Tab>('schedule');

  const tabs: { key: Tab; label: string; icon: string }[] = [
    { key: 'schedule', label: lang === 'zh' ? '行程安排' : 'Schedule', icon: '🗓️' },
    { key: 'tips', label: lang === 'zh' ? '出海须知' : 'Tips', icon: '⚠️' },
    { key: 'license', label: lang === 'zh' ? '鱼证指南' : 'License', icon: '📋' },
    { key: 'seasons', label: lang === 'zh' ? '鱼季信息' : 'Seasons', icon: '📅' },
  ];

  const schedule = [
    { time: '7:55', zh: '码头集合、鱼证核验、安全须知', en: 'Dock check-in, license verification, safety briefing' },
    { time: '8:00', zh: '出发！下虾笼/蟹笼，前往钓点（30-60分钟）', en: 'Depart! Set prawn/crab traps, head to fishing spot (30-60 min)' },
    { time: '9:00', zh: '开始钓鱼，船长指导钓鱼技巧', en: 'Begin fishing, captain guides on techniques' },
    { time: '12:00', zh: '船上午餐休息', en: 'Lunch break on board' },
    { time: '16:00', zh: '收笼、查看渔获、返航', en: 'Collect traps, check catch, return to dock' },
    { time: '17:00', zh: '到达码头，渔获处理，推荐附近餐厅代烹', en: 'Arrive at dock, catch processing, nearby restaurant cooking' },
  ];

  const inclusions = [
    { zh: '全套专业钓具', en: 'Complete fishing gear', icon: '🎣' },
    { zh: '救生衣', en: 'Life jackets', icon: '🦺' },
    { zh: '鱼饵', en: 'Bait', icon: '🪱' },
    { zh: 'GPS鱼探仪', en: 'GPS fish finder', icon: '📡' },
    { zh: '独立卫生间', en: 'Private washroom', icon: '🚻' },
    { zh: '商业保险', en: 'Commercial insurance', icon: '🛡️' },
    { zh: '晕船药', en: 'Seasick pills', icon: '💊' },
  ];

  const tips = {
    wear: [
      { zh: '多层穿着（海上温差大）', en: 'Layered clothing (temperature varies at sea)' },
      { zh: '防滑鞋（甲板会湿）', en: 'Non-slip shoes (deck gets wet)' },
      { zh: '帽子和偏光太阳镜', en: 'Hat & polarized sunglasses' },
      { zh: '防风外套', en: 'Windbreaker jacket' },
    ],
    bring: [
      { zh: 'SPF50+防晒霜', en: 'SPF50+ sunscreen' },
      { zh: '自带午餐和零食（船上不提供食物）', en: 'Packed lunch & snacks (no food on board)' },
      { zh: '水和饮料', en: 'Water & drinks' },
      { zh: '手机防水袋', en: 'Waterproof phone case' },
      { zh: '打印的鱼证（必须纸质版）', en: 'Printed fishing license (paper copy required)' },
    ],
    safety: [
      { zh: '避免过量饮酒', en: 'No excessive alcohol' },
      { zh: '听从船长指挥', en: "Follow captain's instructions" },
      { zh: '晕船时到甲板看远处地平线', en: 'If seasick: go to deck, look at horizon' },
      { zh: '注意鱼钩安全', en: 'Hook safety awareness' },
      { zh: '12岁以下需成人陪同，5岁以下不建议', en: 'Under 12 must have adult; not recommended for under 5' },
    ],
  };

  return (
    <section id="guide" className="py-24 relative overflow-hidden">
      {/* Decorative */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[200px] bg-gold-400/5 rounded-full blur-[100px]" />

      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        <AnimateOnScroll>
          <div className="text-center mb-12">
            <span className="text-gold-400 text-sm font-semibold tracking-wider uppercase">
              {lang === 'zh' ? '出海指南' : 'Fishing Guide'}
            </span>
            <h2 className="text-3xl md:text-4xl font-heading font-extrabold text-white mt-3 mb-4">
              {lang === 'zh' ? '海钓全攻略' : 'Everything You Need to Know'}
            </h2>
            <p className="text-white/60 text-base max-w-lg mx-auto">
              {lang === 'zh' ? '一站式了解行程、装备、鱼证和最佳鱼季' : 'Trip schedule, gear, licenses, and best fishing seasons'}
            </p>
            <div className="w-12 h-1 bg-gradient-to-r from-gold-400 to-gold-500 mx-auto rounded-full mt-4" />
          </div>
        </AnimateOnScroll>

        {/* Inclusions bar */}
        <AnimateOnScroll delay={100}>
          <div className="mb-10 glass rounded-2xl p-5">
            <h3 className="text-xs font-bold text-gold-400/80 uppercase tracking-wider mb-3">
              {lang === 'zh' ? '费用已包含' : 'Included in Every Trip'}
            </h3>
            <div className="flex flex-wrap gap-3">
              {inclusions.map((item, i) => (
                <span key={i} className="inline-flex items-center gap-1.5 bg-gold-500/10 text-gold-500 text-xs font-medium px-3 py-1.5 rounded-lg border border-gold-500/15">
                  <span>{item.icon}</span>
                  {lang === 'zh' ? item.zh : item.en}
                </span>
              ))}
            </div>
          </div>
        </AnimateOnScroll>

        {/* Tabs */}
        <div className="flex flex-wrap gap-2 mb-8 justify-center">
          {tabs.map(t => (
            <button
              key={t.key}
              onClick={() => setTab(t.key)}
              className={`flex items-center gap-1.5 px-5 py-2.5 rounded-xl text-sm font-semibold transition-all ${
                tab === t.key
                  ? 'bg-gold-400 text-sea-900 shadow-md shadow-gold-400/20'
                  : 'bg-white/5 text-white/60 border border-white/10 hover:border-gold-400/30 hover:text-gold-400'
              }`}
            >
              <span>{t.icon}</span> {t.label}
            </button>
          ))}
        </div>

        {/* Tab Content */}
        <div className="glass rounded-2xl overflow-hidden">
          {/* Schedule */}
          {tab === 'schedule' && (
            <div className="p-6 sm:p-8">
              <h3 className="text-lg font-bold text-white mb-1">
                {lang === 'zh' ? '典型一日行程（约9.5小时）' : 'Typical Day Trip (~9.5 hours)'}
              </h3>
              <p className="text-sm text-white/40 mb-6">
                {lang === 'zh' ? '以下为标准行程，实际根据天气和鱼情可能调整' : 'Standard schedule; may vary based on conditions'}
              </p>
              <div className="relative">
                {/* Timeline line */}
                <div className="absolute left-[52px] top-2 bottom-2 w-px bg-gradient-to-b from-gold-400 via-gold-500/50 to-transparent hidden sm:block" />
                <div className="space-y-4">
                  {schedule.map((s, i) => (
                    <div key={i} className="flex gap-4 items-start group">
                      <div className="flex-shrink-0 w-[52px] text-right">
                        <span className="text-sm font-bold text-gold-400 font-mono">{s.time}</span>
                      </div>
                      <div className="hidden sm:block flex-shrink-0 w-3 h-3 rounded-full bg-gold-400 mt-1.5 ring-4 ring-gold-400/10 group-hover:ring-gold-400/20 transition-all" />
                      <div className="flex-1 bg-white/5 rounded-xl px-4 py-3 group-hover:bg-white/10 transition-colors border border-transparent group-hover:border-gold-400/10">
                        <p className="text-sm text-white/80 font-medium">{lang === 'zh' ? s.zh : s.en}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Tips */}
          {tab === 'tips' && (
            <div className="p-6 sm:p-8">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {/* Wear */}
                <div>
                  <h4 className="flex items-center gap-2 text-sm font-bold text-white mb-3">
                    <span className="w-7 h-7 rounded-lg bg-sky-500/15 text-sky-400 flex items-center justify-center text-xs">👕</span>
                    {lang === 'zh' ? '穿着建议' : 'What to Wear'}
                  </h4>
                  <ul className="space-y-2">
                    {tips.wear.map((t, i) => (
                      <li key={i} className="flex items-start gap-2 text-sm text-white/60">
                        <span className="text-gold-400 mt-0.5">•</span>
                        {lang === 'zh' ? t.zh : t.en}
                      </li>
                    ))}
                  </ul>
                </div>
                {/* Bring */}
                <div>
                  <h4 className="flex items-center gap-2 text-sm font-bold text-white mb-3">
                    <span className="w-7 h-7 rounded-lg bg-amber-500/15 text-amber-400 flex items-center justify-center text-xs">🎒</span>
                    {lang === 'zh' ? '必带物品' : 'What to Bring'}
                  </h4>
                  <ul className="space-y-2">
                    {tips.bring.map((t, i) => (
                      <li key={i} className="flex items-start gap-2 text-sm text-white/60">
                        <span className="text-gold-500 mt-0.5">•</span>
                        {lang === 'zh' ? t.zh : t.en}
                      </li>
                    ))}
                  </ul>
                </div>
                {/* Safety */}
                <div>
                  <h4 className="flex items-center gap-2 text-sm font-bold text-white mb-3">
                    <span className="w-7 h-7 rounded-lg bg-red-500/15 text-red-400 flex items-center justify-center text-xs">⚠️</span>
                    {lang === 'zh' ? '安全须知' : 'Safety'}
                  </h4>
                  <ul className="space-y-2">
                    {tips.safety.map((t, i) => (
                      <li key={i} className="flex items-start gap-2 text-sm text-white/60">
                        <span className="text-red-400 mt-0.5">•</span>
                        {lang === 'zh' ? t.zh : t.en}
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </div>
          )}

          {/* License */}
          {tab === 'license' && (
            <div className="p-6 sm:p-8">
              <div className="bg-amber-500/10 border border-amber-500/20 rounded-xl p-4 mb-6 flex items-start gap-3">
                <span className="text-amber-400 text-lg mt-0.5">⚠️</span>
                <div>
                  <p className="text-sm font-semibold text-amber-300">
                    {lang === 'zh' ? 'BC省法律要求所有钓鱼者持有有效鱼证（包括16岁以下）' : 'BC law requires all anglers to have a valid fishing license (including under 16)'}
                  </p>
                  <p className="text-xs text-amber-400/70 mt-1">
                    {lang === 'zh' ? '必须携带纸质打印版，手机截图不被接受' : 'Must carry printed paper copy — digital screenshots NOT accepted'}
                  </p>
                </div>
              </div>

              <h4 className="text-sm font-bold text-white mb-4">
                {lang === 'zh' ? '在线办理步骤（5分钟）' : 'Online Application (5 minutes)'}
              </h4>
              <div className="grid grid-cols-1 sm:grid-cols-5 gap-3 mb-6">
                {[
                  { step: 1, zh: '注册政府账号', en: 'Create govt account' },
                  { step: 2, zh: '邮箱激活', en: 'Email activation' },
                  { step: 3, zh: '选择太平洋区域+鱼种', en: 'Select Pacific region' },
                  { step: 4, zh: '信用卡付款', en: 'Credit card payment' },
                  { step: 5, zh: '下载并打印PDF', en: 'Download & print PDF' },
                ].map(s => (
                  <div key={s.step} className="flex sm:flex-col items-center gap-2 sm:gap-1 text-center bg-white/5 rounded-xl p-3 border border-white/5">
                    <div className="w-7 h-7 rounded-full bg-gold-400 text-sea-900 text-xs font-bold flex items-center justify-center flex-shrink-0">{s.step}</div>
                    <span className="text-xs text-white/70 font-medium">{lang === 'zh' ? s.zh : s.en}</span>
                  </div>
                ))}
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                {[
                  { zh: '1日证', en: '1-Day License', desc_zh: '偶尔钓鱼', desc_en: 'Occasional trips' },
                  { zh: '5日证', en: '5-Day License', desc_zh: '多次出海更划算', desc_en: 'Multiple trips (better value)' },
                  { zh: '年证', en: 'Annual License', desc_zh: '经常钓鱼首选', desc_en: 'Frequent anglers (best)' },
                ].map((l, i) => (
                  <div key={i} className="border border-white/10 rounded-xl p-4 text-center hover:border-gold-400/25 transition-colors">
                    <div className="text-sm font-bold text-white">{lang === 'zh' ? l.zh : l.en}</div>
                    <div className="text-xs text-white/50 mt-1">{lang === 'zh' ? l.desc_zh : l.desc_en}</div>
                  </div>
                ))}
              </div>

              <div className="mt-6 text-center">
                <a
                  href="https://www.pac.dfo-mpo.gc.ca/fm-gp/rec/licence-permis/application-eng.html"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 btn-gold text-sm px-6 py-3 rounded-xl transition-all"
                >
                  {lang === 'zh' ? '前往办理鱼证' : 'Apply for License'}
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" />
                  </svg>
                </a>
              </div>
            </div>
          )}

          {/* Seasons */}
          {tab === 'seasons' && (
            <div className="p-6 sm:p-8">
              <h3 className="text-sm font-bold text-white mb-1">
                {lang === 'zh' ? '温哥华全年钓鱼日历' : 'Vancouver Year-Round Fishing Calendar'}
              </h3>
              <p className="text-xs text-white/40 mb-6">
                {lang === 'zh' ? '绿色方块表示当月可钓该鱼种' : 'Green blocks indicate species availability'}
              </p>

              {/* Month headers */}
              <div className="overflow-x-auto">
                <div className="min-w-[600px]">
                  <div className="grid grid-cols-[140px_repeat(12,1fr)] gap-1 mb-2">
                    <div />
                    {MONTH_LABELS.map(m => (
                      <div key={m} className="text-[10px] font-semibold text-white/40 text-center">{m}</div>
                    ))}
                  </div>
                  {FISH_SEASONS.map((fish, i) => (
                    <div key={i} className="grid grid-cols-[140px_repeat(12,1fr)] gap-1 mb-1.5 items-center">
                      <div className="flex items-center gap-2">
                        <span className="text-base">{fish.icon}</span>
                        <span className="text-xs font-medium text-white/80 truncate">
                          {lang === 'zh' ? fish.zh : fish.en}
                        </span>
                      </div>
                      {Array.from({ length: 12 }, (_, m) => (
                        <div
                          key={m}
                          className={`h-6 rounded ${
                            fish.months.includes(m + 1)
                              ? 'bg-gold-400/70'
                              : 'bg-white/5'
                          }`}
                        />
                      ))}
                    </div>
                  ))}
                </div>
              </div>

              <div className="mt-6 bg-white/5 rounded-xl p-4 border border-white/10">
                <h4 className="text-xs font-bold text-gold-400/80 mb-2">
                  {lang === 'zh' ? '温馨提示' : 'Tips'}
                </h4>
                <ul className="space-y-1 text-xs text-white/60">
                  <li>• {lang === 'zh' ? '全年可钓：斑点虾季、珍宝蟹、各类底鱼' : 'Year-round: Spot prawn season, Dungeness crab, groundfish'}</li>
                  <li>• {lang === 'zh' ? '6-9月：三文鱼旺季，是最热门的海钓时段' : '6-9月: Peak salmon season — most popular fishing period'}</li>
                  <li>• {lang === 'zh' ? '具体开放日期以DFO官方公告为准' : 'Exact dates subject to DFO official announcements'}</li>
                </ul>
              </div>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
