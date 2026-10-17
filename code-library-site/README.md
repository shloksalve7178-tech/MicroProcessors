# My Code Library — Read-only website

A simple searchable code viewer. It does not edit or run your code. On each build it scans `public/code/`, creates a file index automatically, and lets you open and copy the files in a browser.

## 1. Add your code

1. Extract this project folder.
2. Open `public/code/`.
3. Copy your code files and folders into it. Keep the folder structure you want to see in the sidebar. For example:

   ```text
   public/code/
   ├── Microprocessor/
   │   ├── addition.asm
   │   └── subtraction.asm
   ├── DSA/
   │   └── linked_list.c
   └── Python/
       └── calculator.py
   ```

4. You do not need to edit a list or manually register each file. The build script scans supported code/text extensions automatically.

Supported types include C/C++, Python, Java, JavaScript/TypeScript, HTML/CSS, 8086 `.asm`, SQL, JSON, Markdown, shell scripts, and many others. Hidden files and common private-key/secret file names/extensions are skipped; do not rely on that filter as a security boundary.

## 2. Deploy with GitHub + Vercel

1. Create a GitHub account if you do not already have one, then install **GitHub Desktop**.
2. Create a new repository from this extracted project folder in GitHub Desktop, and publish it to GitHub. A private repository protects the source repository, but **does not make the deployed website private**.
3. Sign in to Vercel and choose **Add New → Project**.
4. Import the repository you just published. Vercel should detect Vite. Set the build command to `npm run build` and the output directory to `dist` if they are not filled automatically.
5. Deploy. Vercel will give you a website URL.

Official guides: https://docs.github.com/en/desktop/overview/creating-your-first-repository-using-github-desktop and https://vercel.com/docs/deployments

## 3. Add or update files later

Copy new files into `public/code/`, then commit and push the change using GitHub Desktop. Vercel redeploys from the connected repository. The file index is regenerated during the build.

## 4. Preview on your computer (optional)

Install Node.js, open a terminal in this project folder, and run:

```bash
npm install
npm run dev
```

Open the local URL printed by Vite (usually http://localhost:5173). To test the production build, run `npm run build` and then `npm run preview`.

## Important privacy note

This is a read-only **viewer**, not a private file vault. Every file included in `public/code/` is served by the deployed site and may be accessible to anyone who has or discovers its URL. Do not put passwords, API keys, `.env` files, personal data, private assignments, or confidential code into a public deployment. If you need private viewing, use an authenticated/protected deployment before uploading sensitive content.
