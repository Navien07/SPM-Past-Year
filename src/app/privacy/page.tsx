import Link from "next/link";

export const metadata = { title: "Privacy Policy & PDPA Notice, SPM AI" };

export default function PrivacyPage() {
  return (
    <div className="mx-auto max-w-3xl space-y-6 py-4">
      <Link href="/" className="text-sm text-brand-600 hover:underline">← Back</Link>
      <div>
        <h1 className="text-2xl font-bold">Privacy Policy &amp; PDPA Notice</h1>
        <p className="text-sm text-slate-500">SPM AI, pilot programme. Last updated: June 2026.</p>
      </div>

      <div className="card space-y-5 p-6 text-sm leading-relaxed text-slate-700">
        <p>
          This notice explains how <strong>SPM AI</strong> (&quot;we&quot;, &quot;us&quot;) collects, uses and
          protects your personal data in accordance with Malaysia&apos;s <strong>Personal Data Protection
          Act 2010 (PDPA)</strong>. By creating an account you consent to the practices below.
        </p>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">1. Data we collect</h2>
          <ul className="list-inside list-disc space-y-1">
            <li>Account details: your name, email address and form (Tingkatan 4/5).</li>
            <li>Your <strong>WhatsApp number</strong>, used to add you to the pilot feedback group.</li>
            <li>Learning activity: subjects, attempts, answers, scores, time spent and progress.</li>
            <li>Content you submit, including screenshots you attach in the AI chat.</li>
          </ul>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">2. Why we use it</h2>
          <ul className="list-inside list-disc space-y-1">
            <li>To run your account and provide AI grading, tutoring and practice.</li>
            <li>To personalise your revision (weak topics, spaced repetition, recommendations).</li>
            <li><strong>To analyse your learning, behaviour and performance</strong>, including learning analytics,
              usage patterns, and psychometric/aptitude analysis, to understand how students learn and to improve
              the service and our models.</li>
            <li>To produce aggregated and anonymised research, insights and statistics.</li>
            <li>To contact you with pilot updates and gather feedback via the WhatsApp group.</li>
          </ul>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">3. Ownership &amp; intellectual property</h2>
          <p>
            All content on the platform (questions, notes, AI outputs, design and software) and <strong>all
            insights, analytics, models and data derived from your use of SPM AI</strong> are owned by SPM AI.
            <strong> All rights reserved.</strong> We may use de-identified/aggregated data indefinitely for research,
            product development and commercial purposes. You retain ownership of the personal data you provide and
            your rights under the PDPA (section 7).
          </p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">4. Processing &amp; third parties</h2>
          <p>
            Your data is stored on our hosting and database providers (e.g. Vercel and Supabase). AI
            features send your questions/answers/images to our AI provider (Anthropic) to generate
            responses. These providers process data on our behalf under their own security terms. We do
            <strong> not</strong> sell your personal data.
          </p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">5. WhatsApp feedback group</h2>
          <p>
            With your consent, we use your WhatsApp number to add you to a pilot feedback group. Other
            members may see your number and name. You can leave the group at any time and ask us to
            remove your number.
          </p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">6. Retention</h2>
          <p>
            We keep your data for the duration of the pilot and a reasonable period afterwards, then
            delete or anonymise it. You may request deletion of your account and data at any time.
          </p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">7. Your rights (PDPA)</h2>
          <p>
            You may access, correct, or withdraw consent to the processing of your personal data, and
            request deletion, by contacting us. Withdrawing consent may mean we can no longer provide the
            service.
          </p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">8. Security</h2>
          <p>
            Passwords are stored hashed (never in plain text) and sessions use secure, http-only cookies.
            No system is perfectly secure, but we take reasonable steps to protect your data.
          </p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">9. Contact</h2>
          <p>To exercise your rights or ask questions, contact the SPM AI team via the pilot WhatsApp group or your administrator.</p>
        </section>

        <p className="rounded-xl bg-amber-50 p-3 text-xs text-amber-800">
          Note: this notice is provided for the pilot programme and is not legal advice. Please have it
          reviewed by a qualified professional before a full public launch.
        </p>
      </div>
    </div>
  );
}
