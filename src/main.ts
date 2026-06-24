// ボタンクリックでモーダルを開閉する最小ロジック。
// E2E テスト (tests/modal.spec.ts) がこの挙動を検証する。

const openButton = document.querySelector<HTMLButtonElement>("#open-modal");
const closeButton = document.querySelector<HTMLButtonElement>("#close-modal");
const modal = document.querySelector<HTMLDialogElement>("#modal");

openButton?.addEventListener("click", () => {
  modal?.showModal();
});

closeButton?.addEventListener("click", () => {
  modal?.close();
});
