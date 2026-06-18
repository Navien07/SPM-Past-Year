import type { Config } from "tailwindcss";

export default {
  content: [
    "./src/app/**/*.{ts,tsx}",
    "./src/components/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50: "#eef5ff",
          100: "#d9e8ff",
          200: "#bcd6ff",
          300: "#8ebcff",
          400: "#5996ff",
          500: "#3470f4",
          600: "#1f50e0",
          700: "#1b3fc4",
          800: "#1c379f",
          900: "#1c337d",
        },
        // Teal "AI" accent from the logo.
        accent: {
          50: "#eafff7",
          100: "#c8fceb",
          200: "#93f6d8",
          300: "#56e9c1",
          400: "#27d3ac",
          500: "#14b896",
          600: "#0d9479",
          700: "#0f7763",
          800: "#115e50",
          900: "#124d43",
        },
      },
      fontFamily: {
        sans: ["var(--font-sans)", "system-ui", "sans-serif"],
        display: ["var(--font-display)", "var(--font-sans)", "sans-serif"],
      },
    },
  },
  plugins: [],
} satisfies Config;
