/** Name given to a budget that arrives without one. Mobile uses the same text. */
export const DEFAULT_BUDGET_NAME = 'Unnamed budget';

/** Longest budget name accepted. Mobile limits its form field to the same. */
export const BUDGET_NAME_MAX_LENGTH = 100;

/**
 * Most names one `POST /budgets/names` request may carry. Mobile sends batches
 * of this size. Small enough that a full batch of long names stays under the
 * default 100kb JSON body limit.
 */
export const FILL_BUDGET_NAMES_MAX_ITEMS = 200;
