private import go as G
private import Concepts as C
private import semmle.go.controlflow.ControlFlowGraphImpl as CFG

module Private {
  predicate edge(Node n1, Node n2) { n1.getASuccessor() = n2 }

  class Callable = G::FuncDef;

  predicate callTarget(CallNode call, Callable target) { none() }

  predicate flowEntry(Callable c, Node entry) { c.getBody().getFirstControlFlowNode() = entry }

  predicate flowExit(Callable c, Node exitNode) {
    exitNode.isExitNode() and
    c = getEnclosingCallable(exitNode)
  }

  Callable getEnclosingCallable(Node n) { result = n.getBasicBlock().getRoot() }

  class Split extends TSplit {
    abstract string toString();

    abstract G::Location getLocation();

    abstract predicate entry(Node n1, Node n2);

    abstract predicate exit(Node n1, Node n2);

    abstract predicate blocked(Node n1, Node n2);
  }
}

private import Private

private newtype TSplit = TSplitUnit()

private newtype TLabel =
  TLabelUnit() or
  TLabelChannel(C::ChannelCreation cc, C::SendingAnonymousGoroutine r) {
    cc.getAWrite().getEnclosingFunction() = r and
    cc.isUnbuffered()
  }

module Public {
  class Node = G::ControlFlow::Node;

  class CallNode extends Node {
    CallNode() { this = CFG::MkExprNode(any(G::CallExpr e)) }
  }

  abstract class Label extends TLabel {
    abstract string toString();
  }

  class Position extends int {
    Position() { 0 = this }
  }

  class LabelUnit extends Label, TLabelUnit {
    override string toString() { result = "labelunit" }
  }

  class LabelChannel extends Label, TLabelChannel {
    C::ChannelCreation cc;
    C::SendingAnonymousGoroutine r;

    LabelChannel() { this = TLabelChannel(cc, r) }

    C::ChannelCreation getChannelCreation() { result = cc }

    C::SendingAnonymousGoroutine getSendingAnonymousGoroutine() { result = r }

    override string toString() { result = cc.toString() + ":" + r.toString() }
  }
}

private import Public
