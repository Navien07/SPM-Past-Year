import Link from "next/link";

export const metadata = { title: "Terms of Use — SPM AI" };

export default function TermsPage() {
  return (
    <div className="mx-auto max-w-3xl space-y-6 py-4">
      <Link href="/" className="text-sm text-brand-600 hover:underline">Back</Link>
      <div>
        <h1 className="text-2xl font-bold">Terms of Use</h1>
        <p className="text-sm text-slate-500">SPM AI pilot programme. Last updated: June 2026.</p>
      </div>

      <div className="card space-y-5 p-6 text-sm leading-relaxed text-slate-700">
        <p>By creating an account or using <strong>SPM AI</strong> you agree to these Terms and to our{" "}
          <Link href="/privacy" className="font-semibold text-brand-600 hover:underline">Privacy Policy &amp; PDPA Notice</Link>.</p>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">1. Eligibility</h2>
          <p>SPM AI is for students preparing for the SPM examination. If you are under 18, you confirm that your
            parent or guardian has read and agreed to these Terms and the Privacy Policy on your behalf.</p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">2. Licence to use</h2>
          <p>We grant you a personal, non-transferable, non-commercial licence to use SPM AI for your own revision.
            You may not copy, scrape, resell, redistribute, or build a competing product from the platform or its content.</p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">3. Intellectual property &amp; data</h2>
          <p>All software, design, questions, notes, AI outputs, and <strong>all insights, analytics, models and data
            derived from use of the platform</strong> are the property of SPM AI. <strong>All rights reserved.</strong>
            By using SPM AI you grant us the right to collect, store and analyse your usage and content (including for
            learning analytics and psychometric/aptitude analysis) as described in the Privacy Policy.</p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">4. Acceptable use</h2>
          <p>Do not misuse the service, attempt to access other users&apos; data, disrupt the platform, or upload unlawful
            content. We may suspend accounts that breach these Terms.</p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">5. Educational aid &amp; disclaimer</h2>
          <p>SPM AI is a study aid. AI-generated grading and explanations may contain errors and are not a guarantee of
            exam results. SPM AI is an independent product and is not affiliated with, or endorsed by, the Lembaga
            Peperiksaan or the Ministry of Education.</p>
        </section>

        <section>
          <h2 className="mb-1 font-bold text-slate-900">6. Termination &amp; governing law</h2>
          <p>You may stop using SPM AI and request account deletion at any time. These Terms are governed by the laws of
            Malaysia.</p>
        </section>

        <p className="rounded-xl bg-amber-50 p-3 text-xs text-amber-800">
          Note: provided for the pilot and not legal advice. Have these Terms reviewed by a qualified professional before
          a full public launch.
        </p>
      </div>
    </div>
  );
}
