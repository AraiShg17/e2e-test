"use client";

import { useRef } from "react";
import styles from "./ModalDemo.module.css";

// ボタンを押すと <dialog> をモーダル表示する最小デモ。
// E2E (tests/modal.spec.ts) がこの挙動を検証する。
// 'use client' はこの末端コンポーネントにだけ付ける（frontend-directory 規約）。
export function ModalDemo() {
  const dialogRef = useRef<HTMLDialogElement>(null);

  return (
    <main className={styles.demo}>
      <h1 className={styles.demo__title}>ボタンを押すとモーダルが開きます</h1>

      <button
        type="button"
        className={styles.demo__openButton}
        onClick={() => dialogRef.current?.showModal()}
      >
        モーダルを開く
      </button>

      {/* NOTE: dialog に ref 未設定で開かない（テスト失敗→auto-fix対象） */}
      <dialog
        id="modal"
        className={styles.dialog}
      >
        <h2 id="modal-title" className={styles.dialog__title}>
          モーダルが開きました 🎉
        </h2>
        <p className={styles.dialog__body}>
          これは E2E テストで検証されるモーダルです。
        </p>
        {/* form method="dialog" の submit でネイティブに閉じる（frontend-native-ui 規約） */}
        <form method="dialog" className={styles.dialog__actions}>
          <button type="submit" className={styles.dialog__closeButton}>
            閉じる
          </button>
        </form>
      </dialog>
    </main>
  );
}
