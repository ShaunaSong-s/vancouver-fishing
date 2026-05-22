import { NextRequest, NextResponse } from 'next/server';

/**
 * 微信云开发 HTTP API 工具
 * 网站预约通过此模块写入小程序同一个云数据库
 * 
 * 需要在 .env.local 配置:
 *   WX_CLOUD_ENV=cloudbase-d2gdsz2cvdf12be4b
 *   WX_APPID=wx3d795ebfc2ff12cc
 *   WX_APPSECRET=<your-app-secret>
 */

const WX_CLOUD_ENV = process.env.WX_CLOUD_ENV || 'cloudbase-d2gdsz2cvdf12be4b';
const WX_APPID = process.env.WX_APPID || 'wx3d795ebfc2ff12cc';
const WX_APPSECRET = process.env.WX_APPSECRET || '';

let cachedToken: { token: string; expiresAt: number } | null = null;

/** 获取微信 access_token (带缓存) */
async function getAccessToken(): Promise<string> {
  if (cachedToken && Date.now() < cachedToken.expiresAt - 60000) {
    return cachedToken.token;
  }

  const url = `https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=${WX_APPID}&secret=${WX_APPSECRET}`;
  const res = await fetch(url);
  const data = await res.json();

  if (!data.access_token) {
    throw new Error(`Failed to get access_token: ${JSON.stringify(data)}`);
  }

  cachedToken = {
    token: data.access_token,
    expiresAt: Date.now() + data.expires_in * 1000,
  };

  return cachedToken.token;
}

/** 向微信云数据库写入一条记录 */
export async function addToCloudDB(collection: string, data: Record<string, unknown>): Promise<string> {
  const token = await getAccessToken();

  // Ensure collection exists (auto-create if needed)
  await ensureCollection(token, collection);

  const url = `https://api.weixin.qq.com/tcb/databaseadd?access_token=${token}`;

  const query = `db.collection("${collection}").add({ data: ${JSON.stringify(data)} })`;

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ env: WX_CLOUD_ENV, query }),
  });

  const result = await res.json();
  if (result.errcode !== 0) {
    throw new Error(`Cloud DB error: ${result.errmsg}`);
  }

  // result.id_list 包含新增记录的 _id
  return result.id_list?.[0] || '';
}

const createdCollections = new Set<string>();

/** 确保集合存在，不存在则创建 */
async function ensureCollection(token: string, collection: string): Promise<void> {
  if (createdCollections.has(collection)) return;

  const url = `https://api.weixin.qq.com/tcb/databasecollectionadd?access_token=${token}`;
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ env: WX_CLOUD_ENV, collection_name: collection }),
  });
  const result = await res.json();
  // errcode 0 = created, -502005 = already exists — both are fine
  if (result.errcode === 0 || result.errcode === -502005) {
    createdCollections.add(collection);
  }
}

/** 查询微信云数据库 */
export async function queryCloudDB(collection: string, where: string): Promise<unknown[]> {
  const token = await getAccessToken();
  const url = `https://api.weixin.qq.com/tcb/databasequery?access_token=${token}`;

  const query = `db.collection("${collection}").where(${where}).limit(100).get()`;

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ env: WX_CLOUD_ENV, query }),
  });

  const result = await res.json();
  if (result.errcode !== 0) {
    throw new Error(`Cloud DB query error: ${result.errmsg}`);
  }

  return (result.data || []).map((d: string) => JSON.parse(d));
}

/** 更新微信云数据库记录 */
export async function updateCloudDB(collection: string, docId: string, data: Record<string, unknown>): Promise<void> {
  const token = await getAccessToken();
  const url = `https://api.weixin.qq.com/tcb/databaseupdate?access_token=${token}`;

  const query = `db.collection("${collection}").doc("${docId}").update({data: ${JSON.stringify(data)}})`;

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ env: WX_CLOUD_ENV, query }),
  });

  const result = await res.json();
  if (result.errcode !== 0) {
    throw new Error(`Cloud DB update error: ${result.errmsg}`);
  }
}
