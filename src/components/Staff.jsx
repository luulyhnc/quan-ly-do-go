import { useCallback, useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'

const roleLabel = role => role === 'owner' ? 'Chủ xưởng' : role === 'admin' ? 'Quản lý' : 'Chỉ xem'

export default function Staff() {
  const [rows, setRows] = useState([])
  const [email, setEmail] = useState('')
  const [fullName, setFullName] = useState('')
  const [role, setRole] = useState('viewer')
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')

  const refresh = useCallback(async () => {
    setLoading(true)
    const { data, error: queryError } = await supabase.rpc('list_wood_staff')
    if (queryError) setError(queryError.message)
    else { setRows(data || []); setError('') }
    setLoading(false)
  }, [])

  useEffect(() => { void refresh() }, [refresh])

  async function submit(event) {
    event.preventDefault()
    setSaving(true); setError(''); setNotice('')
    const { error: rpcError } = await supabase.rpc('assign_wood_role', {
      p_email: email.trim(), p_full_name: fullName.trim(), p_role: role,
    })
    if (rpcError) setError(rpcError.message)
    else {
      setNotice('Đã cập nhật quyền. Nhân viên có thể đăng nhập bằng tài khoản Auth đã được xác nhận.')
      setEmail(''); setFullName(''); setRole('viewer')
      await refresh()
    }
    setSaving(false)
  }

  return <div className="staff-page">
    <div className="page-intro"><div><h2>Nhân sự xưởng gỗ</h2><p>Chỉ chủ xưởng được phân quyền. Tài khoản phải được tạo trước trong Supabase Authentication.</p></div></div>
    <section className="panel">
      <header><h3>Cấp quyền cho nhân viên</h3></header>
      <form className="form" onSubmit={submit}>
        <label>Email tài khoản Supabase<input type="email" required value={email} onChange={e => setEmail(e.target.value)} placeholder="nhanvien@example.com"/></label>
        <label>Họ tên<input value={fullName} onChange={e => setFullName(e.target.value)} placeholder="Tên nhân viên"/></label>
        <label>Vai trò<select value={role} onChange={e => setRole(e.target.value)}><option value="admin">Quản lý — được nhập, xuất và sửa dữ liệu</option><option value="viewer">Chỉ xem — không được sửa dữ liệu</option></select></label>
        <div className="form-actions"><button className="primary" type="submit" disabled={saving}>{saving ? 'Đang lưu...' : 'Cấp / cập nhật quyền'}</button></div>
      </form>
      {error && <div className="alert">{error}</div>}
      {notice && <p className="form-hint">{notice}</p>}
    </section>
    <section className="panel">
      <header><h3>Danh sách tài khoản được cấp quyền</h3><button className="link" type="button" onClick={refresh}>Làm mới</button></header>
      {loading ? <p>Đang tải danh sách...</p> : <div className="table-wrap"><table><thead><tr><th>Nhân viên</th><th>Email</th><th>Quyền</th><th>Ngày cấp</th></tr></thead><tbody>{rows.map(row => <tr key={row.user_id}><td><b>{row.full_name || 'Chưa đặt tên'}</b></td><td>{row.email || '—'}</td><td><span className="badge posted">{roleLabel(row.role)}</span></td><td>{row.created_at ? new Date(row.created_at).toLocaleDateString('vi-VN') : '—'}</td></tr>)}</tbody></table></div>}
    </section>
  </div>
}
