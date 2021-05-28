import go

class ChannelCreation extends CallExpr {
  ChannelCreation() {
    this.getTarget().getName() = "make" and this.getArgument(0) instanceof ChanTypeExpr
  }

  predicate isBuffered() { exists(this.getArgument(1)) }

  predicate isUnbuffered() { not isBuffered() }

  SendStmt getAWrite() {
    DataFlow::localFlow(DataFlow::exprNode(this), DataFlow::exprNode(result.getChannel()))
  }

  RecvStmt getARead() {
    DataFlow::localFlow(DataFlow::exprNode(this), DataFlow::exprNode(result.getExpr().getOperand()))
  }
}

class AnonymousGoroutine extends FuncLit {
  AnonymousGoroutine() { this.getParent().(CallExpr).getParent() instanceof GoStmt }

  GoStmt getGoStmt() { result = this.getParent().getParent() }
}

class SendingAnonymousGoroutine extends AnonymousGoroutine {
  ChannelCreation cc;

  SendingAnonymousGoroutine() { cc.getAWrite().getEnclosingFunction() = this }
}
