export const metadata = { title: "Offline — SPM AI" };

export default function OfflinePage() {
  return (
    <div className="card mx-auto max-w-md p-8 text-center">
      <div className="text-5xl">📡</div>
      <h1 className="mt-3 text-xl font-bold">You&apos;re offline</h1>
      <p className="mt-2 text-sm text-slate-600">
        SPM AI needs a connection for instant AI grading and the Cikgu AI tutor. Reconnect and
        your practice will pick up right where you left off.
      </p>
      <a href="/" className="btn-primary mt-5 inline-flex">Try again</a>
    </div>
  );
}
