import { IDataSourcePrefetching } from '@kit.ArkUI';

type ItemIndex = number;
type TimerId = number;

export class QueueDataSource implements IDataSourcePrefetching {
  private listeners: DataChangeListener[] = [];
  public data: string[] = [];
  private readonly fetchDelayMs: number;
  private readonly fetches: Map<ItemIndex, TimerId> = new Map();

  constructor(pageNum: number, pageSize: number, fetchDelayMs: number) {
    this.data = [];
    this.fetchDelayMs = fetchDelayMs;
    this.getHttpData(pageNum, pageSize);
  }

  prefetch(index: number): Promise<void> {
    // Simulate time-consuming operations.
    return new Promise<void>(resolve => {
      const timeoutId = setTimeout(async () => {
        this.fetches.delete(index);
        resolve();
      }, this.fetchDelayMs);
      this.fetches.set(index, timeoutId)
    });
  }

  cancel?(index: number): void | Promise<void> {
    const timerId = this.fetches.get(index);
    if (timerId) {
      this.fetches.delete(index);
      clearTimeout(timerId);
    }
  }

  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): string {
    return this.data[index]
  }

  getAllData(): string[] {
    return this.data;
  }

  getHttpData(pageNum: number, pageSize: number): void {
    const newItems: string[] = [];
    for (let i = (pageNum - 1) * pageSize; i < pageNum * pageSize; i++) {
      const item = `A-${i.toString().padStart(3, '0')}`
      newItems.push(item);
    }
    const startIndex = this.data.length;
    this.data.splice(startIndex, 0, ...newItems);
    this.notifyBatchUpdate([
      {
        type: DataOperationType.ADD,
        index: startIndex,
        count: newItems.length,
        key: newItems
      }
    ]);
  }

  private notifyBatchUpdate(operations: DataOperation[]) {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDatasetChange(operations);
    });
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  delete(index: number) {
    this.data.splice(index, 1);
    this.notifyDataDelete(index);
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }
}