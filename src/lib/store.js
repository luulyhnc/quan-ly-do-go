import { seed } from './demoData'
const KEY='do-go-manager-v1'
export function firstLetter(name){const plain=String(name||'').trim().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/Đ/g,'D').replace(/đ/g,'d');return (plain.match(/[A-Za-z]/)?.[0]||'X').toUpperCase()}
export function migrateMaterialCodes(input){const data=structuredClone(input);const counters={};const seen=new Set();data.materials=data.materials.map(m=>{const prefix=firstLetter(m.name);let code=String(m.code||'').trim().toUpperCase();const match=code.match(/^([A-Z])(\d{5})$/);if(match&&match[1]===prefix&&!seen.has(code)){counters[prefix]=Math.max(counters[prefix]||0,Number(match[2]))}else{do{counters[prefix]=(counters[prefix]||0)+1;code=`${prefix}${String(counters[prefix]).padStart(5,'0')}`}while(seen.has(code))}seen.add(code);return {...m,code}});return data}
export function load(){ try{return migrateMaterialCodes(JSON.parse(localStorage.getItem(KEY))||structuredClone(seed))}catch{return migrateMaterialCodes(seed)} }
export function save(data){localStorage.setItem(KEY,JSON.stringify(data))}
export function reset(){localStorage.removeItem(KEY);return structuredClone(seed)}
export function nextMaterialCode(materials,name){const prefix=firstLetter(name);const n=Math.max(0,...materials.filter(x=>firstLetter(x.name)===prefix).map(x=>Number(String(x.code).match(/\d{5}$/)?.[0])||0))+1;return `${prefix}${String(n).padStart(5,'0')}`}
export const money=n=>new Intl.NumberFormat('vi-VN').format(Math.round(n||0))+' đ'
export const number=n=>new Intl.NumberFormat('vi-VN',{maximumFractionDigits:3}).format(n||0)
