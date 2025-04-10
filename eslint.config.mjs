import nextEslint from "@next/eslint-plugin-next";
import tseslint from "typescript-eslint";
import reactRecommended from "eslint-plugin-react/configs/recommended.js";

export default [
  reactRecommended,
  ...tseslint.configs.recommended,
  {
    plugins: {
      "@next/next": nextEslint,
    },
    rules: {
      // Keep your existing rules
      "@next/next/no-html-link-for-pages": "off",
      // Add this to fix the "parse" serialization error
      "@typescript-eslint/parser": "off"  // Disable problematic parser config
    },
    // Explicitly set the parser to avoid conflicts
    languageOptions: {
      parser: "@typescript-eslint/parser",
      parserOptions: {
        project: "./tsconfig.json",
      },
    },
  },
];
