#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Validate command line arguments
if (process.argv.length < 3) {
  console.error('Usage: node generate-report.js <artillery-json-file>');
  process.exit(1);
}

const jsonFilePath = process.argv[2];

// Check if file exists
if (!fs.existsSync(jsonFilePath)) {
  console.error(`Error: File not found: ${jsonFilePath}`);
  process.exit(1);
}

// Read Artillery JSON report
const artilleryData = JSON.parse(fs.readFileSync(jsonFilePath, 'utf8'));

// Read HTML template
const templatePath = path.join(__dirname, 'report-template.html');
const template = fs.readFileSync(templatePath, 'utf8');

// Process Artillery data
const processedData = processArtilleryData(artilleryData);

// Inject data into template
const html = template.replace(
  '/*INJECT_DATA_HERE*/',
  `const artilleryData = ${JSON.stringify(processedData, null, 2)};`
);

// Generate output filename
const outputPath = jsonFilePath.replace('.json', '.html');

// Write HTML report
fs.writeFileSync(outputPath, html, 'utf8');

console.log(`✅ HTML report generated: ${outputPath}`);

/**
 * Process Artillery data into a format optimized for visualization
 */
function processArtilleryData(data) {
  const aggregate = data.aggregate || {};
  const intermediate = data.intermediate || [];

  // Extract overall metrics
  const summary = extractSummaryMetrics(aggregate, intermediate);
  const endpoints = extractEndpointMetrics(aggregate);
  const analysis = calculateAnalysisMetrics(summary, intermediate);

  return {
    summary,
    endpoints,
    analysis,
    metadata: extractMetadata(data),
    timeSeries: extractTimeSeries(intermediate),
    httpCodes: extractHttpCodes(aggregate),
    errors: extractErrors(aggregate)
  };
}

/**
 * Extract summary metrics
 */
function extractSummaryMetrics(aggregate, intermediate) {
  const counters = aggregate.counters || {};
  const rates = aggregate.rates || {};
  const summaries = aggregate.summaries || {};

  const httpRequests = counters['http.requests'] || 0;
  const httpResponses = counters['http.responses'] || 0;
  const scenariosCompleted = counters['vusers.completed'] || 0;
  const scenariosCreated = counters['vusers.created'] || 0;

  // Response time statistics
  const responseTime = summaries['http.response_time'] || {};

  // Calculate total errors
  const totalErrors = Object.keys(counters)
    .filter(key => key.startsWith('errors.'))
    .reduce((sum, key) => sum + counters[key], 0);

  // Calculate throughput (requests per second)
  const testDurationSeconds = intermediate.length * 10; // Artillery reports every 10 seconds
  const throughput = testDurationSeconds > 0 ? httpRequests / testDurationSeconds : 0;

  const successRate = httpRequests > 0 ? ((httpResponses / httpRequests) * 100).toFixed(2) : 0;
  const errorRate = httpRequests > 0 ? ((totalErrors / httpRequests) * 100).toFixed(2) : 0;

  return {
    totalRequests: httpRequests,
    totalResponses: httpResponses,
    totalErrors,
    scenariosCompleted,
    scenariosCreated,
    successRate,
    errorRate,
    throughput,
    responseTime: {
      min: responseTime.min || 0,
      max: responseTime.max || 0,
      median: responseTime.median || 0,
      p95: responseTime.p95 || 0,
      p99: responseTime.p99 || 0,
      mean: responseTime.mean || 0
    }
  };
}

/**
 * Calculate analysis and decision metrics
 */
function calculateAnalysisMetrics(summary, intermediate) {
  const rt = summary.responseTime;

  // Apdex Score (T = 1000ms = 1 second)
  // Apdex = (Satisfied + Tolerating/2) / Total
  // Satisfied: <= 1s, Tolerating: <= 4s, Frustrated: > 4s
  const apdexThreshold = 1000; // 1 second
  const toleratingThreshold = 4000; // 4 seconds

  // Estimate distribution based on percentiles
  const satisfied = rt.median <= apdexThreshold ? 0.75 : rt.p95 <= apdexThreshold ? 0.50 : 0.25;
  const tolerating = rt.p95 <= toleratingThreshold ? 0.20 : 0.10;
  const apdex = (satisfied + tolerating / 2).toFixed(2);

  // Consistency Score (Coefficient of Variation)
  // Lower is better, measures response time variance
  const cv = rt.mean > 0 ? ((rt.p95 - rt.median) / rt.mean * 100).toFixed(0) : 0;

  // Tail Ratio (P95 / Median)
  // Ideally should be < 2x
  const tailRatio = rt.median > 0 ? (rt.p95 / rt.median).toFixed(2) : 0;

  // Error Budget (assuming 99.9% SLO)
  const slo = 99.9;
  const actualAvailability = parseFloat(summary.successRate);
  const errorBudgetConsumed = ((slo - actualAvailability) / (100 - slo) * 100).toFixed(1);

  // Test duration
  const durationSeconds = intermediate.length * 10;
  const minutes = Math.floor(durationSeconds / 60);
  const seconds = durationSeconds % 60;
  const testDuration = `${minutes}m ${seconds}s`;

  return {
    apdex: parseFloat(apdex),
    consistencyScore: parseInt(cv),
    tailRatio: parseFloat(tailRatio),
    errorBudgetConsumed: parseFloat(errorBudgetConsumed),
    testDuration
  };
}

/**
 * Extract time series data for charts
 */
function extractTimeSeries(intermediate) {
  return intermediate.map((snapshot, idx) => {
    const counters = snapshot.counters || {};
    const summaries = snapshot.summaries || {};
    const responseTime = summaries['http.response_time'] || {};

    return {
      timestamp: idx,
      requests: counters['http.requests'] || 0,
      responses: counters['http.responses'] || 0,
      responseTime: {
        min: responseTime.min || 0,
        max: responseTime.max || 0,
        median: responseTime.median || 0,
        p95: responseTime.p95 || 0,
        p99: responseTime.p99 || 0
      },
      errors: (counters['errors.ETIMEDOUT'] || 0) +
        (counters['errors.ECONNREFUSED'] || 0) +
        (counters['errors.ENOTFOUND'] || 0)
    };
  });
}

/**
 * Extract per-endpoint metrics
 */
function extractEndpointMetrics(aggregate) {
  const summaries = aggregate.summaries || {};
  const endpoints = [];

  // Find all endpoint-specific summaries
  for (const [key, value] of Object.entries(summaries)) {
    // Look for Artillery plugin format: "plugins.metrics-by-endpoint.response_time./endpoint/path"
    let match = key.match(/^plugins\.metrics-by-endpoint\.response_time\.(.+)$/);
    if (match) {
      const url = match[1];

      endpoints.push({
        method: 'GET',
        url,
        metrics: {
          min: value.min || 0,
          max: value.max || 0,
          median: value.median || 0,
          p95: value.p95 || 0,
          p99: value.p99 || 0,
          mean: value.mean || 0
        }
      });
      continue;
    }

    // Also check for standard format: "http.response_time.GET /endpoint"
    match = key.match(/^http\.response_time\.(GET|POST|PUT|DELETE|PATCH)\s+(.+)$/);
    if (match) {
      const method = match[1];
      const url = match[2];

      endpoints.push({
        method,
        url,
        metrics: {
          min: value.min || 0,
          max: value.max || 0,
          median: value.median || 0,
          p95: value.p95 || 0,
          p99: value.p99 || 0,
          mean: value.mean || 0
        }
      });
    }
  }

  return endpoints;
}

/**
 * Extract HTTP status code distribution
 */
function extractHttpCodes(aggregate) {
  const counters = aggregate.counters || {};
  const codes = {};

  for (const [key, value] of Object.entries(counters)) {
    const match = key.match(/^http\.codes\.(\d+)$/);
    if (match) {
      codes[match[1]] = value;
    }
  }

  return codes;
}

/**
 * Extract error information
 */
function extractErrors(aggregate) {
  const counters = aggregate.counters || {};
  const errors = {};

  for (const [key, value] of Object.entries(counters)) {
    if (key.startsWith('errors.')) {
      const errorType = key.replace('errors.', '');
      errors[errorType] = value;
    }
  }

  return errors;
}

/**
 * Extract metadata from Artillery test
 */
function extractMetadata(data) {
  const aggregate = data.aggregate || {};
  const counters = aggregate.counters || {};

  // Extract scenario name from counters (e.g., vusers.created_by_name.ScenarioName)
  const scenarioKey = Object.keys(counters).find(key => key.startsWith('vusers.created_by_name.'));
  const scenarioName = scenarioKey ? scenarioKey.replace('vusers.created_by_name.', '') : 'Unknown Scenario';

  return {
    timestamp: aggregate.firstCounterAt || new Date().getTime(),
    scenarioName: scenarioName,
    phases: (data.config && data.config.phases) || []
  };
}
