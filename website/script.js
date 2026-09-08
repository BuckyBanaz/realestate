const form = document.querySelector('#deletionForm');

form?.addEventListener('submit', (event) => {
  event.preventDefault();

  const formData = new FormData(form);
  const name = String(formData.get('name') || '').trim();
  const phone = String(formData.get('phone') || '').trim();
  const message = String(formData.get('message') || '').trim() || 'Please delete my BLA Real Estate account and associated personal data.';

  const body = [
    'Hello BLA Real Estate Support,',
    '',
    message,
    '',
    `Full name: ${name || '[please enter your name]'}`,
    `Registered mobile number: ${phone || '[please enter your mobile number]'}`,
    '',
    'I understand that some records may be retained where required by law, security, dispute resolution, fraud prevention, or compliance obligations.',
  ].join('\n');

  const mailtoUrl = new URL('mailto:bandlhisarpvt.ltd@gmail.com');
  mailtoUrl.searchParams.set('subject', 'Account Deletion Request - BLA Real Estate');
  mailtoUrl.searchParams.set('body', body);

  window.location.href = mailtoUrl.toString();
});
