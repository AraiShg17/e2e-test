import { ModalDemo } from "@/features/modal-demo/ModalDemo";

// Server Component。app/ は URL 境界と feature の呼び出しに徹し、
// 画面実装は features/ に置く（frontend-directory 規約）。
export default function Page() {
  return <ModalDemo />;
}
