private import go as G
private import Concepts as C

module Private {
  predicate edge(Node n1, Node n2) { n1.getASuccessor() = n2 }
}

private import Private

private newtype TLabel =
  TLabelUnit() or
  TLabelChannel(C::ChannelCreation cc, C::SendingAnonymousGoroutine r) {
    cc.getAWrite().getEnclosingFunction() = r and
    cc.isUnbuffered()
  }

module Public {
  class Node = G::ControlFlow::Node;

  abstract class Label extends TLabel {
    abstract string toString();
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
