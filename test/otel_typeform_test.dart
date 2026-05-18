// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_typeform/otel_typeform.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_typeform-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('responses.list records form + completion + pagination', () async {
    await tracedTypeform<String>(
      operation: 'responses.list',
      invoke: () async => const TypeformCallResult(
        value: 'ok',
        result: TypeformResult(
          workspaceId: 'ws_1',
          formId: 'frm_1',
          formType: 'quiz',
          fields: 8,
          calculatedFields: 2,
          logicJumps: 3,
          responsesReturned: 25,
          totalResponses: 1480,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('typeform responses.list')!);
    expect(a['typeform.form.type'], 'quiz');
    expect(a['typeform.form.fields'], 8);
    expect(a['typeform.form.calculated_fields'], 2);
    expect(a['typeform.responses.total'], 1480);
  });

  test('single response records device + country + completed', () async {
    await tracedTypeform<String>(
      operation: 'responses.list',
      invoke: () async => const TypeformCallResult(
        value: 'ok',
        result: TypeformResult(
          responseId: 'r_1',
          completed: true,
          metadataPlatform: 'mobile',
          metadataBrowser: 'mobile-webview',
          country: 'US',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('typeform responses.list')!);
    expect(a['typeform.response.completed'], true);
    expect(a['typeform.metadata.platform'], 'mobile');
    expect(a['typeform.metadata.country'], 'US');
  });

  test('HTTP 401 sets span error', () async {
    await tracedTypeform<String>(
      operation: 'webhooks.create',
      invoke: () async => const TypeformCallResult(
        value: 'ok',
        result: TypeformResult(statusCode: 401),
      ),
    );
    expect(
      spans.findSpanByName('typeform webhooks.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutTypeformInstrumentationAsync(() async {
      await tracedTypeform<String>(
        operation: 'forms.list',
        invoke: () async => const TypeformCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('typeform '), isEmpty);
  });
}
