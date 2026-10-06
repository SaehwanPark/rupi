// Owned fake HTTP fixture; never sends a request to the configured model endpoint.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createServer } from 'node:http';
import { once } from 'node:events';
import { pathToFileURL } from 'node:url';

const [bundle, configPath] = process.argv.slice(2);
assert(bundle && configPath, 'Pass the pinned Pi adapter bundle and owned models.json.');
const config = JSON.parse(await readFile(configPath, 'utf8'));
const provider = config.providers.unsloth;
const template = provider.models[0];
assert.equal(template.compat.thinkingFormat, 'chat-template');
assert.deepEqual(template.compat.chatTemplateKwargs,
  { enable_thinking: { $var: 'thinking.enabled' } });
const seen = [];
const server = createServer(async (request, response) => {
  const chunks = [];
  for await (const chunk of request) chunks.push(chunk);
  seen.push(JSON.parse(Buffer.concat(chunks).toString('utf8')));
  response.writeHead(200, { 'content-type': 'text/event-stream' });
  response.end('data: ' + JSON.stringify({ choices: [{ delta: { content: 'owned' } }] })
    + '\n\ndata: ' + JSON.stringify({ choices: [{ delta: {}, finish_reason: 'stop' }],
      usage: { prompt_tokens: 1, completion_tokens: 1, total_tokens: 2 } })
    + '\n\ndata: [DONE]\n\n');
});
server.listen(0, '127.0.0.1');
await once(server, 'listening');
const address = server.address();
assert(address && typeof address === 'object');
assert(![8000, 8001, 8002, 8003].includes(address.port));
const model = { ...template, api: provider.api, provider: 'unsloth',
  baseUrl: `http://127.0.0.1:${address.port}/v1`, input: ['text'],
  cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } };
try {
  const { streamSimple } = await import(pathToFileURL(bundle).href);
  for (const level of ['off', 'low']) {
    const stream = streamSimple(model, { messages: [{ role: 'user',
      content: 'owned dialect fixture', timestamp: Date.now() }] },
    { apiKey: 'local', reasoning: level, maxTokens: 32,
      signal: AbortSignal.timeout(10000) });
    const result = await stream.result();
    assert.equal(result.stopReason, 'stop', result.errorMessage);
  }
  assert.equal(seen.length, 2);
  for (const [index, body] of seen.entries()) {
    assert.deepEqual(body.chat_template_kwargs, { enable_thinking: index === 1 });
    assert(!Object.hasOwn(body, 'reasoning_effort'));
    assert.equal(body.model, template.id);
  }
  console.log('Owned pinned Pi template wire passed: Off false,Low true,exact key,no extra effort.');
} finally {
  server.closeAllConnections();
  await new Promise(resolve => server.close(resolve));
}
