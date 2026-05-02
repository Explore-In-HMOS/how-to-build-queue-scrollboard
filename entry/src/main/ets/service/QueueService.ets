import { getRandomSeconds } from '../lib/utils';
import { QueueDataSource } from '../model/QueueDataSource';
import { BasicPrefetcher } from '@ohos.arkui.Prefetcher';

@Observed
export class QueueService {
  static queue: QueueService | null = null;
  private intervalTimer: number = -1;
  private timer: number = -1;
  @Track scroller: Scroller = new Scroller();
  @Track listScroller: ListScroller = new ListScroller();
  private _page: number = 1;
  private _pageSize: number = 50;
  private readonly _fetchDelayMs: number = 500;
  private _breakPoint: number = 25;
  @Track datasource: QueueDataSource = new QueueDataSource(this._page, this._pageSize, this._fetchDelayMs);
  @Track currentQueueIndex: number = 0;
  @Track currentQueue: string = this.datasource.getData(this.currentQueueIndex);
  @Track message: string = '';
  private prefetcher = new BasicPrefetcher(this.datasource);
  dialogController: CustomDialogController | null = null;

  constructor() {
  }

  static getInstance() {
    if (QueueService.queue === null) {
      QueueService.queue = new QueueService();
    }

    return QueueService.queue;
  }

  get breakpoint() {
    return this._breakPoint;
  }

  onAppear(index: number) {
    if (index >= this.breakpoint) {
      this.datasource.getHttpData(++this._page, this._pageSize);
      this._breakPoint = this.datasource.totalCount() - this._pageSize / 2;
    }
  }

  destroy() {
    this.dialogController = null;
    this.clearTimers();
  }

  showMessage(message: string) {
    this.message = message;
    this.dialogController?.open();
    this.clearTimers();
  }

  visibleAreaChanged(start: number, end: number) {
    this.prefetcher.visibleAreaChanged(start, end);
  }

  clearTimers() {
    clearInterval(this.intervalTimer);
    clearTimeout(this.timer);
  }

  startHorizontalInterval() {
    this.timer = setInterval(() => {
      let current = this.scroller.currentOffset().xOffset;
      this.scroller.scrollTo({ xOffset: current + 10, yOffset: 0, animation: true });
      if (current > 1500) {
        this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
      }
    }, 20)
  }

  startInterval() {
    this.clearTimers();
    this.intervalTimer = setInterval(() => {
      this.scroller.scrollToIndex(this.currentQueueIndex + 2);
      this.listScroller.scrollToIndex(this.currentQueueIndex);
      if (this.currentQueueIndex >= this.datasource.totalCount()) {
        clearInterval(this.intervalTimer);
        this.currentQueueIndex = this.datasource.totalCount() - 1;
        this.currentQueue = 'End';
        return;
      }
      this.currentQueueIndex += 1;
      this.currentQueue = this.datasource.getData(this.currentQueueIndex);
      this.message = `Your turn \n${this.currentQueue}`;
      this.dialogController?.open();
      this.timer = setTimeout(() => {
        this.dialogController?.close();
      }, getRandomSeconds());
    }, 5000);
  }

  private isItemProcessed(item: string) {
    const index = this.datasource.getAllData().indexOf(item);
    return index < this.currentQueueIndex;
  }

  isQueueCurrentItem(item: string) {
    return this.currentQueue === item;
  }

  getBgColor(item: string) {
    if (this.isItemProcessed(item)) {
      return Color.Gray;
    }
    return this.isQueueCurrentItem(item) ? Color.Green : '#1A1A1A';
  }

  getSubtitleText(item: string) {
    if (this.isItemProcessed(item)) {
      return 'processed';
    }
    return this.isQueueCurrentItem(item) ? 'processing...' : 'waiting...';
  }
}