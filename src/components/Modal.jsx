import { X } from 'lucide-react'
export default function Modal({title,onClose,children,wide=false}){return <div className="overlay" onMouseDown={e=>e.target===e.currentTarget&&onClose()}><section className={`modal ${wide?'modal-wide':''}`}><header><h2>{title}</h2><button className="icon" onClick={onClose}><X/></button></header>{children}</section></div>}
