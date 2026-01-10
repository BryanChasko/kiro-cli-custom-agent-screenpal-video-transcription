const { trace } = require('@opentelemetry/api');

const tracer = trace.getTracer('video-processing-pipeline');

function instrumentVideoProcessing(videoId, operation) {
  return tracer.startSpan(`${operation}`, {
    attributes: {
      'video.id': videoId,
      'video.operation': operation,
    }
  });
}

module.exports = { instrumentVideoProcessing };
