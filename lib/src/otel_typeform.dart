// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_typeform_suppression.dart';

const _tracerName = 'dartastic_otel_libs_typeform';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class TypeformResult {
  const TypeformResult({
    this.workspaceId,
    this.formId,
    this.formType,
    this.fields,
    this.calculatedFields,
    this.logicJumps,
    this.responseId,
    this.completed,
    this.metadataPlatform,
    this.metadataBrowser,
    this.country,
    this.webhookId,
    this.webhookEnabled,
    this.responsesReturned,
    this.totalResponses,
    this.statusCode,
  });

  /// Typeform workspace.
  final String? workspaceId;

  final String? formId;

  /// `quiz` / `regular` — affects whether scoring is involved.
  final String? formType;

  /// Total fields (questions) in the form.
  final int? fields;

  /// Calculated fields (price/score logic).
  final int? calculatedFields;

  /// Number of logic jumps configured.
  final int? logicJumps;

  final String? responseId;

  /// `true` if the response was fully submitted (vs partial).
  final bool? completed;

  /// `mobile` / `tablet` / `other` (Typeform's user_agent classifier).
  final String? metadataPlatform;

  final String? metadataBrowser;

  /// ISO country code from response metadata.
  final String? country;

  final String? webhookId;
  final bool? webhookEnabled;

  /// `items.length` in `responses.list` reply.
  final int? responsesReturned;

  /// `total_items` count.
  final int? totalResponses;

  final int? statusCode;
}

class TypeformCallResult<T> {
  const TypeformCallResult({required this.value, this.result});
  final T value;
  final TypeformResult? result;
}

/// Wraps a Typeform API call in a CLIENT span. [operation] is one of
/// `forms.list`, `forms.get`, `forms.create`, `forms.update`,
/// `responses.list`, `responses.delete`, `webhooks.create`,
/// `webhooks.update`, `webhooks.delete`, `themes.list`,
/// `images.create`, `videos.create`, `workspaces.list`.
Future<T> tracedTypeform<T>({
  required String operation,
  required Future<TypeformCallResult<T>> Function() invoke,
}) async {
  if (typeformInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'typeform',
    'rpc.method': operation,
    'typeform.operation': operation,
  };

  final span = _tracer().startSpan(
    'typeform $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.workspaceId != null) {
        extras.add(OTel.attributeString(
          'typeform.workspace.id',
          r.result!.workspaceId!,
        ));
      }
      if (r.result!.formId != null) {
        extras.add(OTel.attributeString(
          'typeform.form.id',
          r.result!.formId!,
        ));
      }
      if (r.result!.formType != null) {
        extras.add(OTel.attributeString(
          'typeform.form.type',
          r.result!.formType!,
        ));
      }
      if (r.result!.fields != null) {
        extras.add(OTel.attributeInt(
          'typeform.form.fields',
          r.result!.fields!,
        ));
      }
      if (r.result!.calculatedFields != null) {
        extras.add(OTel.attributeInt(
          'typeform.form.calculated_fields',
          r.result!.calculatedFields!,
        ));
      }
      if (r.result!.logicJumps != null) {
        extras.add(OTel.attributeInt(
          'typeform.form.logic_jumps',
          r.result!.logicJumps!,
        ));
      }
      if (r.result!.responseId != null) {
        extras.add(OTel.attributeString(
          'typeform.response.id',
          r.result!.responseId!,
        ));
      }
      if (r.result!.completed != null) {
        extras.add(OTel.attributeBool(
          'typeform.response.completed',
          r.result!.completed!,
        ));
      }
      if (r.result!.metadataPlatform != null) {
        extras.add(OTel.attributeString(
          'typeform.metadata.platform',
          r.result!.metadataPlatform!,
        ));
      }
      if (r.result!.metadataBrowser != null) {
        extras.add(OTel.attributeString(
          'typeform.metadata.browser',
          r.result!.metadataBrowser!,
        ));
      }
      if (r.result!.country != null) {
        extras.add(OTel.attributeString(
          'typeform.metadata.country',
          r.result!.country!,
        ));
      }
      if (r.result!.webhookId != null) {
        extras.add(OTel.attributeString(
          'typeform.webhook.id',
          r.result!.webhookId!,
        ));
      }
      if (r.result!.webhookEnabled != null) {
        extras.add(OTel.attributeBool(
          'typeform.webhook.enabled',
          r.result!.webhookEnabled!,
        ));
      }
      if (r.result!.responsesReturned != null) {
        extras.add(OTel.attributeInt(
          'typeform.responses.returned',
          r.result!.responsesReturned!,
        ));
      }
      if (r.result!.totalResponses != null) {
        extras.add(OTel.attributeInt(
          'typeform.responses.total',
          r.result!.totalResponses!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Typeform HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
