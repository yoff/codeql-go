/**
 * @kind path-problem
 */

import go as G
import Concepts as C
import experimental.ControlFlow.ControlFlow
import experimental.ControlFlow.ControlFlow::ControlFlow
import experimental.ControlFlow.ControlFlow::ControlFlow::PathGraph

class LeakConfiguration extends ControlFlow::Configuration {
  LeakConfiguration() { this = "LeakConfiguration" }

  override predicate isSource(ControlFlow::Node src, ControlFlow::Label l) {
    src.(G::IR::EvalInstruction).getExpr() =
      l.(ControlFlow::LabelChannel).getSendingAnonymousGoroutine()
  }

  override predicate isSink(ControlFlow::Node sink, ControlFlow::Label l) {
    l instanceof ControlFlow::LabelChannel and
    sink.isExitNode()
  }

  override predicate isBarrier(ControlFlow::Node n, ControlFlow::Label l) {
    n = l.(ControlFlow::LabelChannel).getChannelCreation().getARead().getFirstControlFlowNode()
  }
}

from
  ControlFlow::PathNode src, ControlFlow::PathNode sink, LeakConfiguration conf,
  C::ChannelCreation cc, C::SendingAnonymousGoroutine r
where
  conf.hasFlow(src, sink) and
  cc = src.getLabel().(ControlFlow::LabelChannel).getChannelCreation() and
  r = src.getLabel().(ControlFlow::LabelChannel).getSendingAnonymousGoroutine()
select r, src, sink, "This goroutine sends to the unbuffered channel created $@, and might leak.",
  cc, "here"
