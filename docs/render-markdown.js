(function () {
  const escapeHtml = (value) => value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const inline = (value) => escapeHtml(value)
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
    .replace(/\*([^*]+)\*/g, '<em>$1</em>');
  const isTableDivider = (line) => /^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)+\|?\s*$/.test(line);
  const cells = (line) => line.trim().replace(/^\||\|$/g, '').split('|').map((cell) => cell.trim());

  document.querySelectorAll('.source-article').forEach((source) => {
    const lines = source.textContent.replace(/\r/g, '').split('\n');
    const html = [];
    let index = 0;
    while (index < lines.length) {
      const line = lines[index];
      if (!line.trim()) { index += 1; continue; }
      if (/^```/.test(line)) {
        const code = [];
        index += 1;
        while (index < lines.length && !/^```/.test(lines[index])) code.push(lines[index++]);
        if (index < lines.length) index += 1;
        html.push(`<pre class="md-code"><code>${escapeHtml(code.join('\n'))}</code></pre>`);
        continue;
      }
      const heading = line.match(/^(#{1,3})\s+(.+)$/);
      if (heading) {
        const level = Math.min(4, heading[1].length + 1);
        html.push(`<h${level}>${inline(heading[2])}</h${level}>`);
        index += 1;
        continue;
      }
      if (/^---+$/.test(line.trim())) { html.push('<hr>'); index += 1; continue; }
      if (line.startsWith('>')) {
        const quote = [];
        while (index < lines.length && lines[index].startsWith('>')) quote.push(lines[index++].replace(/^>\s?/, ''));
        html.push(`<blockquote><p>${quote.map(inline).join('<br>')}</p></blockquote>`);
        continue;
      }
      if (/^\|/.test(line) && index + 1 < lines.length && isTableDivider(lines[index + 1])) {
        const headers = cells(line);
        index += 2;
        const rows = [];
        while (index < lines.length && /^\|/.test(lines[index])) rows.push(cells(lines[index++]));
        html.push(`<table class="md-table"><thead><tr>${headers.map((cell) => `<th>${inline(cell)}</th>`).join('')}</tr></thead><tbody>${rows.map((row) => `<tr>${row.map((cell) => `<td>${inline(cell)}</td>`).join('')}</tr>`).join('')}</tbody></table>`);
        continue;
      }
      if (/^\|/.test(line)) {
        html.push(`<p>${inline(line)}</p>`);
        index += 1;
        continue;
      }
      if (/^\s*[*-]\s+/.test(line)) {
        const items = [];
        while (index < lines.length && /^\s*[*-]\s+/.test(lines[index])) items.push(lines[index++].replace(/^\s*[*-]\s+/, ''));
        html.push(`<ul>${items.map((item) => `<li>${inline(item)}</li>`).join('')}</ul>`);
        continue;
      }
      const paragraph = [];
      while (index < lines.length && lines[index].trim() && !/^```/.test(lines[index]) && !/^(#{1,3})\s+/.test(lines[index]) && !/^---+$/.test(lines[index].trim()) && !/^>/.test(lines[index]) && !/^\|/.test(lines[index]) && !/^\s*[*-]\s+/.test(lines[index])) paragraph.push(lines[index++]);
      html.push(`<p>${paragraph.map(inline).join('<br>')}</p>`);
    }
    const body = document.createElement('div');
    body.className = 'markdown-body';
    body.innerHTML = html.join('\n');
    source.after(body);
    source.classList.add('is-rendered');
  });
}());
