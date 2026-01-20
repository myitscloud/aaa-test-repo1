/**
 * Jest Test Setup
 * Runs before all tests
 */

// Extend Jest matchers
// require('@testing-library/jest-dom');

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.LOG_LEVEL = 'error';

// Global test timeout
jest.setTimeout(30000);

// Mock console methods to reduce noise (optional)
// global.console = {
//   ...console,
//   log: jest.fn(),
//   debug: jest.fn(),
//   info: jest.fn(),
//   warn: jest.fn(),
//   error: jest.fn(),
// };

// Clean up after all tests
afterAll(async () => {
  // Close any open handles
  // await closeDatabase();
  // await closeServer();
});

// Reset state between tests
beforeEach(() => {
  // Clear all mocks
  jest.clearAllMocks();
});
