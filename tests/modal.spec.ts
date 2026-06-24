import { test, expect } from "@playwright/test";

test.describe("ボタン → モーダル", () => {
  test("初期状態ではモーダルは表示されていない", async ({ page }) => {
    await page.goto("/");
    await expect(page.locator("#modal")).toBeHidden();
  });

  test("ボタンを押すとモーダルが開く", async ({ page }) => {
    await page.goto("/");

    await page.getByRole("button", { name: "モーダルを開く" }).click();

    const modal = page.locator("#modal");
    await expect(modal).toBeVisible();
    await expect(page.getByRole("heading", { name: "モーダルが開きました 🎉" })).toBeVisible();
  });

  test("閉じるボタンでモーダルが閉じる", async ({ page }) => {
    await page.goto("/");

    await page.getByRole("button", { name: "モーダルを開く" }).click();
    await expect(page.locator("#modal")).toBeVisible();

    await page.getByRole("button", { name: "閉じる" }).click();
    await expect(page.locator("#modal")).toBeHidden();
  });
});
