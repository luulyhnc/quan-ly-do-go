import { seed } from './demoData'
const KEY='do-go-manager-v1'
export function load(){ try{return JSON.parse(localStorage.getItem(KEY))||structuredClone(seed)}catch{return structuredClone(seed)} }
export function save(data){localStorage.setItem(KEY,JSON.stringify(data))}
export function reset(){localStorage.removeItem(KEY);return structuredClone(seed)}
export function nextMaterialCode(materials){return `NPL-${String(Math.max(0,...materials.map(x=>Number(x.code?.match(/\d+/)?.[0])||0))+1).padStart(4,'0')}`}
export const money=n=>new Intl.NumberFormat('vi-VN').format(Math.round(n||0))+' đ'
export const number=n=>new Intl.NumberFormat('vi-VN',{maximumFractionDigits:3}).format(n||0)
